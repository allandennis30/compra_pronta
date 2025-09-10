import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../utils/logger.dart';
import '../repositories/entregador_repository.dart';
import '../../../core/utils/result.dart';

class DeliveryListController extends GetxController {
  final EntregadorRepository _repository = Get.find<EntregadorRepository>();
  
  final RxList<OrderModel> _deliveries = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedStatus = 'all'.obs;

  List<OrderModel> get deliveries => _deliveries;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get selectedStatus => _selectedStatus.value;

  final List<String> statusOptions = [
    'all',
    'preparing',
    'ready_for_pickup',
    'delivering',
    'delivered'
  ];

  @override
  void onInit() {
    super.onInit();
    loadDeliveries();
  }

  /// Carrega lista de entregas disponíveis
  Future<void> loadDeliveries() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final Result<List<OrderModel>> result = await _repository.getAvailableDeliveriesR();
      result.when(
        success: (data) {
          _deliveries.assignAll(data);
          AppLogger.info('✅ [DELIVERY_LIST] ${_deliveries.length} entregas carregadas com sucesso');
        },
        failure: (message, {code, exception}) {
          _errorMessage.value = message;
          AppLogger.error('❌ [DELIVERY_LIST] Erro ao carregar entregas: $message', exception);
          Get.snackbar('Erro', message, snackPosition: SnackPosition.BOTTOM);
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshDeliveries() async {
    await loadDeliveries();
  }

  Future<void> filterByStatus(String status) async {
    _selectedStatus.value = status;
    await loadDeliveries();
  }

  /// Aceita uma entrega
  Future<void> acceptDelivery(OrderModel delivery) async {
    _errorMessage.value = '';
    final Result<void> result = await _repository.acceptDeliveryR(delivery.id);
    result.when(
      success: (_) {
        _deliveries.remove(delivery);
        AppLogger.info('✅ [DELIVERY_LIST] Entrega aceita: ${delivery.id}');
        Get.snackbar('Sucesso', 'Entrega aceita com sucesso!', snackPosition: SnackPosition.BOTTOM);
      },
      failure: (message, {code, exception}) {
        _errorMessage.value = message;
        AppLogger.error('❌ [DELIVERY_LIST] Erro ao aceitar entrega: $message', exception);
        Get.snackbar('Erro', message, snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  void goToDeliveryDetail(OrderModel delivery) {
    Get.toNamed('/entregador/delivery-detail', arguments: {
      'deliveryId': delivery.id,
      'delivery': delivery,
    });
  }
}