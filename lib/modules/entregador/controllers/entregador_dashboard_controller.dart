import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../utils/logger.dart';
import '../repositories/entregador_repository.dart';
import '../models/delivery_stats_model.dart';
import '../models/entregador_profile_model.dart';

class EntregadorDashboardController extends GetxController {
  final EntregadorRepository _repository = Get.find<EntregadorRepository>();

  // Estados observáveis
  final Rx<DeliveryStatsModel?> _stats = Rx<DeliveryStatsModel?>(null);
  final Rx<EntregadorProfileModel?> _profile = Rx<EntregadorProfileModel?>(null);
  final RxList<OrderModel> _activeDeliveries = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isAvailable = false.obs;

  // Getters
  Rx<DeliveryStatsModel?> get stats => _stats;
  Rx<EntregadorProfileModel?> get profile => _profile;
  RxList<OrderModel> get activeDeliveries => _activeDeliveries;
  RxBool get isLoading => _isLoading;
  RxString get errorMessage => _errorMessage;
  RxBool get isAvailable => _isAvailable;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Carrega todos os dados do dashboard
  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Carrega dados em paralelo
      await Future.wait([
        loadProfile(),
        loadStats(),
        loadActiveDeliveries(),
      ]);

      AppLogger.info('✅ [DASHBOARD] Dados do dashboard carregados com sucesso');
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar dados do dashboard';
      AppLogger.error('❌ [DASHBOARD] Erro ao carregar dados', e);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Carrega perfil do entregador
  Future<void> loadProfile() async {
    try {
      final profile = await _repository.getProfile();
      _profile.value = profile;
      _isAvailable.value = profile.isAvailable;
      
      AppLogger.info('✅ [DASHBOARD] Perfil carregado: ${profile.name}');
    } catch (e) {
      AppLogger.error('❌ [DASHBOARD] Erro ao carregar perfil', e);
      rethrow;
    }
  }

  /// Carrega estatísticas
  Future<void> loadStats() async {
    try {
      final stats = await _repository.getDeliveryStats();
      _stats.value = stats;
      
      AppLogger.info('✅ [DASHBOARD] Estatísticas carregadas: ${stats.totalDeliveries} entregas');
    } catch (e) {
      AppLogger.error('❌ [DASHBOARD] Erro ao carregar estatísticas', e);
      rethrow;
    }
  }

  /// Carrega entregas ativas
  Future<void> loadActiveDeliveries() async {
    try {
      final deliveries = await _repository.getActiveDeliveries();
      _activeDeliveries.assignAll(deliveries);
      
      AppLogger.info('✅ [DASHBOARD] ${deliveries.length} entregas ativas carregadas');
    } catch (e) {
      AppLogger.error('❌ [DASHBOARD] Erro ao carregar entregas ativas', e);
      rethrow;
    }
  }

  /// Atualiza disponibilidade do entregador
  Future<void> toggleAvailability() async {
    try {
      final newAvailability = !_isAvailable.value;
      
      await _repository.updateAvailability(newAvailability);
      _isAvailable.value = newAvailability;
      
      // Atualiza o perfil local
      if (_profile.value != null) {
        // Como não temos copyWith no modelo, vamos recarregar o perfil
        await loadProfile();
      }
      
      AppLogger.info('✅ [DASHBOARD] Disponibilidade alterada para: $newAvailability');
      
      Get.snackbar(
        'Sucesso',
        newAvailability ? 'Você está disponível para entregas' : 'Você está indisponível',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: newAvailability ? Get.theme.primaryColor : Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      AppLogger.error('❌ [DASHBOARD] Erro ao alterar disponibilidade', e);
      
      Get.snackbar(
        'Erro',
        'Não foi possível alterar sua disponibilidade',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Atualiza todos os dados
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  /// Navega para lista de entregas disponíveis
  void goToAvailableDeliveries() {
    Get.toNamed('/entregador/deliveries/available');
  }

  /// Navega para histórico de entregas
  void goToDeliveryHistory() {
    Get.toNamed('/entregador/deliveries/history');
  }

  /// Navega para perfil do entregador
  void goToProfile() {
    Get.toNamed('/entregador/profile');
  }

  /// Navega para detalhes de uma entrega
  void goToDeliveryDetail(OrderModel delivery) {
    Get.toNamed('/entregador/delivery/${delivery.id}');
  }

  /// Aceita uma entrega rapidamente
  Future<void> quickAcceptDelivery(OrderModel delivery) async {
    try {
      await _repository.acceptDelivery(delivery.id);
      
      // Remove da lista de ativas e recarrega
      _activeDeliveries.remove(delivery);
      await loadActiveDeliveries();
      
      AppLogger.info('✅ [DASHBOARD] Entrega aceita rapidamente: ${delivery.id}');
      
      Get.snackbar(
        'Sucesso',
        'Entrega aceita com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      AppLogger.error('❌ [DASHBOARD] Erro ao aceitar entrega', e);
      
      Get.snackbar(
        'Erro',
        'Não foi possível aceitar a entrega',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Verifica se pode aceitar entregas
  bool get canAcceptDeliveries {
    final profile = _profile.value;
    if (profile == null) return false;
    
    return profile.canAcceptDeliveries && _isAvailable.value;
  }

  /// Retorna mensagem de status
  String get statusMessage {
    final profile = _profile.value;
    if (profile == null) return 'Carregando...';
    
    if (!profile.hasValidDocuments) {
      return 'Documentos pendentes';
    }
    
    if (!profile.isActive) {
      return 'Conta inativa';
    }
    
    if (!_isAvailable.value) {
      return 'Indisponível';
    }
    
    return 'Disponível para entregas';
  }

  /// Retorna cor do status
  String get statusColor {
    final profile = _profile.value;
    if (profile == null) return '#9E9E9E';
    
    if (!profile.hasValidDocuments || !profile.isActive) {
      return '#F44336'; // Vermelho
    }
    
    if (!_isAvailable.value) {
      return '#FF9800'; // Laranja
    }
    
    return '#4CAF50'; // Verde
  }
}