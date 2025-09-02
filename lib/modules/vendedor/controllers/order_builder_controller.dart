import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/logger.dart';
import '../../cliente/models/product_model.dart';
import '../repositories/vendedor_product_repository.dart';

class OrderBuilderController extends GetxController {
  final VendedorProductRepository _productRepository =
      Get.find<VendedorProductRepository>();

  // Estado reativo dos itens do pedido
  final RxList<OrderItemStatus> orderItems = <OrderItemStatus>[].obs;

  // Controle de visibilidade do scanner
  final RxBool isScannerVisible = false.obs;

  // Pedido atual
  final Rx<OrderModel?> _currentOrder = Rx<OrderModel?>(null);
  OrderModel? get currentOrder => _currentOrder.value;

  @override
  void onInit() {
    super.onInit();
    // Receber o pedido como argumento
    final arguments = Get.arguments;
    if (arguments != null && arguments['order'] != null) {
      _currentOrder.value = arguments['order'] as OrderModel;
      _initializeOrderItems();
      AppLogger.info(
          '✅ [ORDER_BUILDER] Pedido carregado: ${_currentOrder.value?.id} - Cliente: ${_currentOrder.value?.clientName}');
    } else {
      // Fallback para evitar erros
      AppLogger.error('❌ [ORDER_BUILDER] Pedido não fornecido nos argumentos');
      Get.back(); // Voltar para a página anterior
    }
  }

  void _initializeOrderItems() {
    if (_currentOrder.value != null) {
      try {
        orderItems.value = _currentOrder.value!.items
            .map((item) => OrderItemStatus(
                  orderItem: item,
                  isScanned: false,
                  product: null,
                  scannedQuantity: 0,
                ))
            .toList();
        AppLogger.info(
            '✅ [ORDER_BUILDER] ${orderItems.length} itens inicializados');
      } catch (e) {
        AppLogger.error('❌ [ORDER_BUILDER] Erro ao inicializar itens:', e);
        orderItems.value = [];
      }
    } else {
      AppLogger.warning(
          '⚠️ [ORDER_BUILDER] Pedido não disponível para inicializar itens');
      orderItems.value = [];
    }
  }

  // Processar código de barras escaneado
  Future<void> processScannedBarcode(String barcode) async {
    try {
      AppLogger.info(
          '🔍 [ORDER_BUILDER] Processando código de barras: $barcode');

      // Buscar produto pelo código de barras
      final product = await _productRepository.getProductByBarcode(barcode);

      if (product != null) {
        AppLogger.info('✅ [ORDER_BUILDER] Produto encontrado: ${product.name}');

        // Verificar se o produto está na lista de itens do pedido
        final itemIndex = orderItems.indexWhere(
          (item) => item.orderItem.productId == product.id,
        );

        if (itemIndex != -1) {
          final currentItem = orderItems[itemIndex];

          // Verificar se já atingiu a quantidade total
          if (currentItem.isComplete) {
            Get.snackbar(
              'Quantidade Completa',
              'Produto ${product.name} já foi escaneado completamente (${currentItem.scannedQuantity}/${currentItem.orderItem.quantity})',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Get.theme.colorScheme.tertiary,
              colorText: Get.theme.colorScheme.onTertiary,
              duration: const Duration(seconds: 2),
            );
            return;
          }

          // Incrementar quantidade escaneada
          final newScannedQuantity = currentItem.scannedQuantity + 1;
          final isNowComplete =
              newScannedQuantity >= currentItem.orderItem.quantity;

          orderItems[itemIndex] = currentItem.copyWith(
            isScanned: newScannedQuantity > 0,
            product: product,
            scannedQuantity: newScannedQuantity,
          );

          if (isNowComplete) {
            Get.snackbar(
              'Item Completo!',
              'Produto ${product.name} escaneado completamente (${newScannedQuantity}/${currentItem.orderItem.quantity})',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Get.theme.colorScheme.primary,
              colorText: Get.theme.colorScheme.onPrimary,
              duration: const Duration(seconds: 2),
            );
          } else {
            Get.snackbar(
              'Produto Adicionado',
              'Produto ${product.name} (${newScannedQuantity}/${currentItem.orderItem.quantity})',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Get.theme.colorScheme.secondary,
              colorText: Get.theme.colorScheme.onSecondary,
              duration: const Duration(seconds: 1),
            );
          }
        } else {
          AppLogger.warning(
              '⚠️ [ORDER_BUILDER] Produto ${product.name} não encontrado na lista do pedido');
          Get.snackbar(
            'Produto não encontrado',
            'Este produto não está na lista do pedido',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        AppLogger.warning(
            '⚠️ [ORDER_BUILDER] Código de barras não reconhecido: $barcode');
        Get.snackbar(
          'Produto não encontrado',
          'Código de barras não reconhecido',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      AppLogger.error(
          '❌ [ORDER_BUILDER] Erro ao processar código de barras: $barcode', e);
      Get.snackbar(
        'Erro',
        'Erro ao processar código de barras: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Verificar se todos os itens foram escaneados completamente
  bool get allItemsScanned => orderItems.every((item) => item.isComplete);

  // Contar itens completamente escaneados
  int get scannedItemsCount =>
      orderItems.where((item) => item.isComplete).length;

  // Total de itens
  int get totalItemsCount => orderItems.length;

  // Progresso em porcentagem baseado em itens completos
  double get progress =>
      totalItemsCount > 0 ? scannedItemsCount / totalItemsCount : 0.0;

  // Progresso detalhado baseado em quantidades
  double get detailedProgress {
    if (orderItems.isEmpty) return 0.0;

    int totalQuantityNeeded =
        orderItems.fold(0, (sum, item) => sum + item.orderItem.quantity);
    int totalQuantityScanned =
        orderItems.fold(0, (sum, item) => sum + item.scannedQuantity);

    return totalQuantityNeeded > 0
        ? totalQuantityScanned / totalQuantityNeeded
        : 0.0;
  }

  // Alternar visibilidade do scanner
  void toggleScannerVisibility() {
    isScannerVisible.value = !isScannerVisible.value;
  }
}

// Classe para representar o status de um item do pedido
class OrderItemStatus {
  final OrderItemModel orderItem;
  final bool isScanned;
  final ProductModel? product;
  final int scannedQuantity;

  OrderItemStatus({
    required this.orderItem,
    required this.isScanned,
    this.product,
    this.scannedQuantity = 0,
  });

  OrderItemStatus copyWith({
    OrderItemModel? orderItem,
    bool? isScanned,
    ProductModel? product,
    int? scannedQuantity,
  }) {
    return OrderItemStatus(
      orderItem: orderItem ?? this.orderItem,
      isScanned: isScanned ?? this.isScanned,
      product: product ?? this.product,
      scannedQuantity: scannedQuantity ?? this.scannedQuantity,
    );
  }

  // Verifica se a quantidade total foi atingida
  bool get isComplete => scannedQuantity >= orderItem.quantity;

  // Progresso do item (0.0 a 1.0)
  double get progress =>
      orderItem.quantity > 0 ? scannedQuantity / orderItem.quantity : 0.0;
}
