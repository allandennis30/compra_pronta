import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/api_service.dart';
import '../../../utils/logger.dart';
import '../models/delivery_stats_model.dart';
import '../models/entregador_profile_model.dart';

class EntregadorRepository {
  final ApiService _apiService = Get.find<ApiService>();

  /// Busca entregas disponíveis para o entregador
  Future<List<OrderModel>> getAvailableDeliveries() async {
    try {
      final response = await _apiService.get('/entregador/deliveries/available');

      if (response['success'] == true) {
        final List<dynamic> deliveriesJson = response['deliveries'] ?? [];
        
        final deliveries = deliveriesJson.map((json) {
          try {
            return OrderModel.fromJson(json);
          } catch (e) {
            AppLogger.error('Erro ao converter entrega', e);
            return null;
          }
        }).where((order) => order != null).cast<OrderModel>().toList();

        AppLogger.info('✅ [ENTREGADOR] ${deliveries.length} entregas disponíveis carregadas');
        return deliveries;
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro na API ao buscar entregas disponíveis', response);
        throw Exception(response['message'] ?? 'Erro ao carregar entregas');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar entregas disponíveis', e);
      rethrow;
    }
  }

  /// Aceita uma entrega
  Future<void> acceptDelivery(String orderId) async {
    try {
      final response = await _apiService.post('/entregador/deliveries/$orderId/accept', {});

      if (response['success'] == true) {
        AppLogger.info('✅ [ENTREGADOR] Entrega aceita: $orderId');
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro ao aceitar entrega', response);
        throw Exception(response['message'] ?? 'Erro ao aceitar entrega');
      }
    } catch (e) {
      AppLogger.error('Erro ao aceitar entrega', e);
      rethrow;
    }
  }

  /// Atualiza o status de uma entrega
  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    try {
      final response = await _apiService.put('/entregador/deliveries/$orderId/status', {
        'status': newStatus,
      });

      if (response['success'] == true) {
        AppLogger.info('✅ [ENTREGADOR] Status da entrega atualizado: $orderId -> $newStatus');
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro ao atualizar status da entrega', response);
        throw Exception(response['message'] ?? 'Erro ao atualizar status');
      }
    } catch (e) {
      AppLogger.error('Erro ao atualizar status da entrega', e);
      rethrow;
    }
  }

  /// Busca entregas em andamento do entregador
  Future<List<OrderModel>> getActiveDeliveries() async {
    try {
      final response = await _apiService.get('/entregador/deliveries/active');

      if (response['success'] == true) {
        final List<dynamic> deliveriesJson = response['deliveries'] ?? [];
        
        final deliveries = deliveriesJson.map((json) {
          try {
            return OrderModel.fromJson(json);
          } catch (e) {
            AppLogger.error('Erro ao converter entrega ativa', e);
            return null;
          }
        }).where((order) => order != null).cast<OrderModel>().toList();

        AppLogger.info('✅ [ENTREGADOR] ${deliveries.length} entregas ativas carregadas');
        return deliveries;
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro na API ao buscar entregas ativas', response);
        throw Exception(response['message'] ?? 'Erro ao carregar entregas ativas');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar entregas ativas', e);
      rethrow;
    }
  }

  /// Busca histórico de entregas do entregador
  Future<List<OrderModel>> getDeliveryHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get('/entregador/deliveries/history?page=$page&limit=$limit');

      if (response['success'] == true) {
        final List<dynamic> deliveriesJson = response['deliveries'] ?? [];
        
        final deliveries = deliveriesJson.map((json) {
          try {
            return OrderModel.fromJson(json);
          } catch (e) {
            AppLogger.error('Erro ao converter entrega do histórico', e);
            return null;
          }
        }).where((order) => order != null).cast<OrderModel>().toList();

        AppLogger.info('✅ [ENTREGADOR] ${deliveries.length} entregas do histórico carregadas (página $page)');
        return deliveries;
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro na API ao buscar histórico', response);
        throw Exception(response['message'] ?? 'Erro ao carregar histórico');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar histórico de entregas', e);
      rethrow;
    }
  }

  /// Busca estatísticas do entregador
  Future<DeliveryStatsModel> getDeliveryStats() async {
    try {
      final response = await _apiService.get('/entregador/stats');

      if (response['success'] == true) {
        final stats = DeliveryStatsModel.fromJson(response['stats'] ?? {});
        AppLogger.info('✅ [ENTREGADOR] Estatísticas carregadas - ${stats.totalDeliveries} entregas');
        return stats;
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro na API ao buscar estatísticas', response);
        throw Exception(response['message'] ?? 'Erro ao carregar estatísticas');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar estatísticas do entregador', e);
      rethrow;
    }
  }

  /// Busca perfil do entregador
  Future<EntregadorProfileModel> getProfile() async {
    try {
      final response = await _apiService.get('/entregador/profile');

      if (response['success'] == true) {
        final profile = EntregadorProfileModel.fromJson(response['profile'] ?? {});
        AppLogger.info('✅ [ENTREGADOR] Perfil carregado - ${profile.name}');
        return profile;
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro na API ao buscar perfil', response);
        throw Exception(response['message'] ?? 'Erro ao carregar perfil');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar perfil', e);
      rethrow;
    }
  }

  /// Busca uma entrega específica por ID
  Future<OrderModel?> getDeliveryById(String orderId) async {
    try {
      final response = await _apiService.get('/entregador/deliveries/$orderId');

      if (response['success'] == true) {
        final deliveryJson = response['delivery'];
        if (deliveryJson != null) {
          final delivery = OrderModel.fromJson(deliveryJson);
          AppLogger.info('✅ [ENTREGADOR] Entrega carregada: $orderId');
          return delivery;
        }
        return null;
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro na API ao buscar entrega', response);
        throw Exception(response['message'] ?? 'Erro ao carregar entrega');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar entrega por ID', e);
      rethrow;
    }
  }

  /// Atualiza disponibilidade do entregador
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      final response = await _apiService.put('/entregador/availability', {
        'is_available': isAvailable,
      });

      if (response['success'] == true) {
        AppLogger.info('✅ [ENTREGADOR] Disponibilidade atualizada: $isAvailable');
      } else {
        AppLogger.error('❌ [ENTREGADOR] Erro ao atualizar disponibilidade', response);
        throw Exception(response['message'] ?? 'Erro ao atualizar disponibilidade');
      }
    } catch (e) {
      AppLogger.error('Erro ao atualizar disponibilidade', e);
      rethrow;
    }
  }
}