import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../repositories/vendor_metrics_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../core/models/order_model.dart';

class VendorMetricsController extends GetxController {
  final VendorMetricsRepository _metricsRepository =
      Get.find<VendorMetricsRepository>();
  final RxList<OrderModel> _recentOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<OrderModel> get recentOrders => _recentOrders;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadMetrics();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _stopAutoRefresh();
    super.onClose();
  }

  Timer? _autoRefreshTimer;

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _refreshMetricsSilently();
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  void _loadMetrics() async {
    _isLoading.value = true;

    try {
      await _loadRecentOrders();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar métricas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadRecentOrders() async {
    try {
      final orders = await _metricsRepository.getRecentOrders();
      _recentOrders.value = orders;
    } catch (e) {
      AppLogger.error('Erro ao carregar pedidos recentes', e);
    }
  }

  /// Atualiza um pedido específico nas métricas quando seu status for alterado
  void updateOrderInMetrics(OrderModel updatedOrder) {
    try {
      // Encontrar o índice do pedido na lista de pedidos recentes
      final index =
          _recentOrders.indexWhere((order) => order.id == updatedOrder.id);

      if (index != -1) {
        // Atualizar o pedido na lista
        _recentOrders[index] = updatedOrder;

        AppLogger.info(
            '✅ [VENDOR_METRICS] Pedido ${updatedOrder.id} atualizado nas métricas');
      } else {
        AppLogger.warning(
            '⚠️ [VENDOR_METRICS] Pedido ${updatedOrder.id} não encontrado nas métricas');
      }
    } catch (e) {
      AppLogger.error(
          '❌ [VENDOR_METRICS] Erro ao atualizar pedido nas métricas', e);
    }
  }

  Future<void> _refreshMetricsSilently() async {
    try {
      await _loadRecentOrders();
    } catch (e) {
      AppLogger.debug('🔄 [VENDOR_METRICS] Refresh silencioso falhou: $e');
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'delivering':
        return 'Em Entrega';
      case 'delivered':
        return 'Entregue';
      default:
        return 'Desconhecido';
    }
  }

  Color getStatusColor(String status) {
    // Usar cores do sistema de temas
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'confirmed':
        return const Color(0xFF2196F3); // Blue
      case 'preparing':
        return const Color(0xFF9C27B0); // Purple
      case 'delivering':
        return const Color(0xFF00BCD4); // Cyan
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      case 'ready':
        return const Color(0xFF388E3C); // Dark Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
