import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../utils/logger.dart';
import '../repositories/entregador_repository.dart';

class DeliveryDetailController extends GetxController {
  final EntregadorRepository _repository = Get.find<EntregadorRepository>();
  final Rx<OrderModel?> _delivery = Rx<OrderModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isUpdatingStatus = false.obs;

  Rx<OrderModel?> get delivery => _delivery;
  RxBool get isLoading => _isLoading;
  RxString get errorMessage => _errorMessage;
  RxBool get isUpdatingStatus => _isUpdatingStatus;

  @override
  void onInit() {
    super.onInit();
    _loadDeliveryFromArguments();
  }

  void _loadDeliveryFromArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      final deliveryData = arguments['delivery'] as OrderModel?;
      if (deliveryData != null) {
        _delivery.value = deliveryData;
        AppLogger.info('Entrega carregada: ${deliveryData.id}');
      } else {
        _errorMessage.value = 'Dados da entrega não encontrados';
        AppLogger.error('Dados da entrega não encontrados nos argumentos');
      }
    } else {
      _errorMessage.value = 'Argumentos não fornecidos';
      AppLogger.error('Argumentos não fornecidos para DeliveryDetailController');
    }
  }

  Future<void> updateDeliveryStatus(String newStatus) async {
    if (_delivery.value == null) {
      _errorMessage.value = 'Entrega não encontrada';
      return;
    }

    try {
      _isUpdatingStatus.value = true;
      _errorMessage.value = '';

      await _repository.updateDeliveryStatus(_delivery.value!.id, newStatus);
      
      // Atualização local do status
      final currentDelivery = _delivery.value!;
      final updatedDelivery = OrderModel(
        id: currentDelivery.id,
        userId: currentDelivery.userId,
        clientName: currentDelivery.clientName,
        clientEmail: currentDelivery.clientEmail,
        clientPhone: currentDelivery.clientPhone,
        items: currentDelivery.items,
        subtotal: currentDelivery.subtotal,
        deliveryFee: currentDelivery.deliveryFee,
        total: currentDelivery.total,
        status: newStatus,
        paymentMethod: currentDelivery.paymentMethod,
        deliveryInstructions: currentDelivery.deliveryInstructions,
        createdAt: currentDelivery.createdAt,
        deliveredAt: currentDelivery.deliveredAt,
        estimatedDeliveryTime: currentDelivery.estimatedDeliveryTime,
        updatedAt: DateTime.now(),
        deliveryAddress: currentDelivery.deliveryAddress,
        notes: currentDelivery.notes,
        sellerId: currentDelivery.sellerId,
        sellerName: currentDelivery.sellerName,
      );
      _delivery.value = updatedDelivery;

      Get.snackbar(
        'Sucesso',
        'Status da entrega atualizado!',
        snackPosition: SnackPosition.BOTTOM,
      );

      AppLogger.info('✅ [DELIVERY_DETAIL] Status atualizado para: $newStatus');
    } catch (e) {
      _errorMessage.value = 'Erro ao atualizar status: $e';
      AppLogger.error('❌ [DELIVERY_DETAIL] Erro ao atualizar status', e);
      
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o status',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  Future<void> startDelivery() async {
    await updateDeliveryStatus('delivering');
  }

  Future<void> completeDelivery() async {
    await updateDeliveryStatus('delivered');
  }

  void openMap() {
    if (_delivery.value?.deliveryAddress != null) {
      // TODO: Implementar abertura do mapa com endereço
      AppLogger.info('Abrindo mapa para: ${_delivery.value!.deliveryAddress}');
      
      Get.snackbar(
        'Mapa',
        'Funcionalidade em desenvolvimento',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void callCustomer() {
    if (_delivery.value?.clientPhone != null) {
      // TODO: Implementar chamada telefônica
      AppLogger.info('Ligando para: ${_delivery.value!.clientPhone}');
      
      Get.snackbar(
        'Telefone',
        'Funcionalidade em desenvolvimento',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadDeliveryDetails() async {
    if (_delivery.value == null) {
      _errorMessage.value = 'Entrega não encontrada';
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      // Recarrega os dados da entrega do servidor
      final updatedDelivery = await _repository.getDeliveryById(_delivery.value!.id);
      if (updatedDelivery != null) {
        _delivery.value = updatedDelivery;
        AppLogger.info('✅ [DELIVERY_DETAIL] Entrega recarregada: ${updatedDelivery.id}');
      }
    } catch (e) {
      _errorMessage.value = 'Erro ao recarregar entrega: $e';
      AppLogger.error('❌ [DELIVERY_DETAIL] Erro ao recarregar entrega', e);
    } finally {
      _isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }
}