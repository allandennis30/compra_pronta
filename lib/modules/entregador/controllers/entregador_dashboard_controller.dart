import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../utils/logger.dart';
import '../repositories/entregador_repository.dart';
import '../models/delivery_stats_model.dart';
import '../models/entregador_profile_model.dart';
import '../../../core/utils/result.dart';

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
    final Result<EntregadorProfileModel> result = await _repository.getProfileR();
    result.when(
      success: (profile) {
        _profile.value = profile;
        _isAvailable.value = profile.isAvailable;
        AppLogger.info('✅ [DASHBOARD] Perfil carregado: ${profile.name}');
      },
      failure: (message, {code, exception}) {
        AppLogger.error('❌ [DASHBOARD] Erro ao carregar perfil: $message', exception);
        throw Exception(message);
      },
    );
  }

  /// Carrega estatísticas
  Future<void> loadStats() async {
    final Result<DeliveryStatsModel> result = await _repository.getDeliveryStatsR();
    result.when(
      success: (stats) {
        _stats.value = stats;
        AppLogger.info('✅ [DASHBOARD] Estatísticas carregadas: ${stats.totalDeliveries} entregas');
      },
      failure: (message, {code, exception}) {
        AppLogger.error('❌ [DASHBOARD] Erro ao carregar estatísticas: $message', exception);
        throw Exception(message);
      },
    );
  }

  /// Carrega entregas ativas
  Future<void> loadActiveDeliveries() async {
    final Result<List<OrderModel>> result = await _repository.getActiveDeliveriesR();
    result.when(
      success: (deliveries) {
        _activeDeliveries.assignAll(deliveries);
        AppLogger.info('✅ [DASHBOARD] ${deliveries.length} entregas ativas carregadas');
      },
      failure: (message, {code, exception}) {
        AppLogger.error('❌ [DASHBOARD] Erro ao carregar entregas ativas: $message', exception);
        throw Exception(message);
      },
    );
  }

  /// Atualiza disponibilidade do entregador
  Future<void> toggleAvailability() async {
    try {
      final newAvailability = !_isAvailable.value;
      final Result<void> result = await _repository.updateAvailabilityR(newAvailability);
      result.when(
        success: (_) async {
          _isAvailable.value = newAvailability;
          if (_profile.value != null) {
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
        },
        failure: (message, {code, exception}) {
          AppLogger.error('❌ [DASHBOARD] Erro ao alterar disponibilidade: $message', exception);
          Get.snackbar(
            'Erro',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
      );
    } catch (_) {}
  }

  /// Aceita uma entrega rapidamente
  Future<void> quickAcceptDelivery(OrderModel delivery) async {
    final Result<void> result = await _repository.acceptDeliveryR(delivery.id);
    result.when(
      success: (_) async {
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
      },
      failure: (message, {code, exception}) {
        AppLogger.error('❌ [DASHBOARD] Erro ao aceitar entrega: $message', exception);
        Get.snackbar(
          'Erro',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      },
    );
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