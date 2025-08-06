import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../cliente/models/product_model.dart';
import '../repositories/vendedor_product_repository.dart';

class OrderBuilderController extends GetxController {
  final VendedorProductRepository _productRepository = Get.find<VendedorProductRepository>();
  
  // Estado reativo dos itens do pedido
  final RxList<OrderItemStatus> orderItems = <OrderItemStatus>[].obs;
  
  // Pedido atual
  late OrderModel currentOrder;
  
  @override
  void onInit() {
    super.onInit();
    // Receber o pedido como argumento
    final arguments = Get.arguments;
    if (arguments != null && arguments['order'] != null) {
      currentOrder = arguments['order'] as OrderModel;
      _initializeOrderItems();
    }
  }
  
  void _initializeOrderItems() {
    orderItems.value = currentOrder.items.map((item) => OrderItemStatus(
      orderItem: item,
      isScanned: false,
      product: null,
    )).toList();
  }
  
  // Processar código de barras escaneado
  Future<void> processScannedBarcode(String barcode) async {
    try {
      // Buscar produto pelo código de barras
      final product = await _productRepository.getProductByBarcode(barcode);
      
      if (product != null) {
        // Verificar se o produto está na lista de itens do pedido
        final itemIndex = orderItems.indexWhere(
          (item) => item.orderItem.productId == product.id,
        );
        
        if (itemIndex != -1) {
          // Marcar item como escaneado
          orderItems[itemIndex] = orderItems[itemIndex].copyWith(
            isScanned: true,
            product: product,
          );
          
          Get.snackbar(
            'Sucesso',
            'Produto ${product.name} encontrado!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        } else {
          Get.snackbar(
            'Produto não encontrado',
            'Este produto não está na lista do pedido',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        }
      } else {
        Get.snackbar(
          'Produto não encontrado',
          'Código de barras não reconhecido',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao processar código de barras: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
  
  // Verificar se todos os itens foram escaneados
  bool get allItemsScanned => orderItems.every((item) => item.isScanned);
  
  // Contar itens escaneados
  int get scannedItemsCount => orderItems.where((item) => item.isScanned).length;
  
  // Total de itens
  int get totalItemsCount => orderItems.length;
  
  // Progresso em porcentagem
  double get progress => totalItemsCount > 0 ? scannedItemsCount / totalItemsCount : 0.0;
}

// Classe para representar o status de um item do pedido
class OrderItemStatus {
  final OrderItemModel orderItem;
  final bool isScanned;
  final ProductModel? product;
  
  OrderItemStatus({
    required this.orderItem,
    required this.isScanned,
    this.product,
  });
  
  OrderItemStatus copyWith({
    OrderItemModel? orderItem,
    bool? isScanned,
    ProductModel? product,
  }) {
    return OrderItemStatus(
      orderItem: orderItem ?? this.orderItem,
      isScanned: isScanned ?? this.isScanned,
      product: product ?? this.product,
    );
  }
}