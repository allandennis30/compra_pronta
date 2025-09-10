import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../utils/logger.dart';
import '../repositories/entregador_repository.dart';

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
      
      final availableDeliveries = await _repository.getAvailableDeliveries();
      _deliveries.assignAll(availableDeliveries);
      
      AppLogger.info('✅ [DELIVERY_LIST] ${_deliveries.length} entregas carregadas com sucesso');
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar entregas: $e';
      AppLogger.error('❌ [DELIVERY_LIST] Erro ao carregar entregas', e);
      Get.snackbar(
        'Erro',
        'Não foi possível carregar as entregas',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshDeliveries() async {
    await loadDeliveries();
  }

  void filterByStatus(String status) {
    _selectedStatus.value = status;
    // Implementar filtro local ou recarregar com filtro
    loadDeliveries();
  }

  /// Aceita uma entrega
  Future<void> acceptDelivery(OrderModel delivery) async {
    try {
      await _repository.acceptDelivery(delivery.id);
      
      // Remove da lista de disponíveis
      _deliveries.remove(delivery);
      
      AppLogger.info('✅ [DELIVERY_LIST] Entrega aceita: ${delivery.id}');
      
      Get.snackbar(
        'Sucesso',
        'Entrega aceita com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorMessage.value = 'Erro ao aceitar entrega: $e';
      AppLogger.error('❌ [DELIVERY_LIST] Erro ao aceitar entrega', e);
      Get.snackbar(
        'Erro',
        'Não foi possível aceitar a entrega',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void goToDeliveryDetail(OrderModel delivery) {
    Get.toNamed('/entregador/delivery-detail', arguments: {
      'deliveryId': delivery.id,
      'delivery': delivery,
    });
  }
}