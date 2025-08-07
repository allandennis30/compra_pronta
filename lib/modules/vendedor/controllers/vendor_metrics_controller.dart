import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../repositories/vendor_metrics_repository.dart';
import '../../../core/utils/logger.dart';

class VendorMetricsController extends GetxController {
  final VendorMetricsRepository _metricsRepository =
      Get.find<VendorMetricsRepository>();
  final RxList<Map<String, dynamic>> _recentOrders =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;

  List<Map<String, dynamic>> get recentOrders => _recentOrders;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadMetrics();
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
    // Note: This method should ideally receive a BuildContext to access theme
    // For now, using Material Design default colors that work in both themes
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'confirmed':
        return const Color(0xFF2196F3); // Blue
      case 'preparing':
        return const Color(0xFF2196F3); // Blue
      case 'delivering':
        return const Color(0xFF2196F3); // Blue
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
