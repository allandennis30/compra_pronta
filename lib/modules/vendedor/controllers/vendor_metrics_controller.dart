import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../repositories/vendor_metrics_repository.dart';
import '../../../core/utils/logger.dart';

class VendorMetricsController extends GetxController {
  final VendorMetricsRepository _metricsRepository =
      Get.find<VendorMetricsRepository>();
  final RxDouble _totalSales = 0.0.obs;
  final RxInt _totalOrders = 0.obs;
  final RxInt _pendingOrders = 0.obs;
  final RxInt _totalProducts = 0.obs;
  final RxList<Map<String, dynamic>> _recentOrders =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _topProducts =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;

  double get totalSales => _totalSales.value;
  int get totalOrders => _totalOrders.value;
  int get pendingOrders => _pendingOrders.value;
  int get totalProducts => _totalProducts.value;
  List<Map<String, dynamic>> get recentOrders => _recentOrders;
  List<Map<String, dynamic>> get topProducts => _topProducts;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadMetrics();
  }

  void _loadMetrics() async {
    _isLoading.value = true;

    try {
      await Future.wait([
        _loadDashboardMetrics(),
        _loadRecentOrders(),
        _loadTopProducts(),
      ]);
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

  Future<void> _loadDashboardMetrics() async {
    try {
      final metrics = await _metricsRepository.getDashboardMetrics();
      _totalSales.value = metrics['totalSales'] ?? 0.0;
      _totalOrders.value = metrics['totalOrders'] ?? 0;
      _pendingOrders.value = metrics['pendingOrders'] ?? 0;
      _totalProducts.value = metrics['totalProducts'] ?? 0;
    } catch (e) {
      AppLogger.error('Erro ao carregar métricas do dashboard', e);
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

  Future<void> _loadTopProducts() async {
    try {
      final products = await _metricsRepository.getTopProducts();
      _topProducts.value = products;
    } catch (e) {
      AppLogger.error('Erro ao carregar produtos mais vendidos', e);
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
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'delivering':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
