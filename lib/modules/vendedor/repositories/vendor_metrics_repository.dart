import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/logger.dart';
import 'vendor_order_repository.dart';

abstract class VendorMetricsRepository {
  Future<Map<String, dynamic>> getDashboardMetrics();
  Future<List<OrderModel>> getRecentOrders();
  Future<List<OrderModel>> getAllOrders();
  Future<List<Map<String, dynamic>>> getTopProducts();
  Future<Map<String, dynamic>> getSalesReport(
      {DateTime? startDate, DateTime? endDate});
}

class VendorMetricsRepositoryImpl implements VendorMetricsRepository {
  late final VendorOrderRepository _orderRepository;

  VendorMetricsRepositoryImpl() {
    _orderRepository = Get.find<VendorOrderRepository>();
  }

  @override
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      // Buscar pedidos reais para calcular métricas
      final orders = await _orderRepository.getVendorOrders();

      // Calcular métricas baseadas nos pedidos reais
      double totalSales = 0.0;
      int totalOrders = orders.length;
      int pendingOrders = 0;

      for (final order in orders) {
        totalSales += order.total;
        if (order.status == 'pending') {
          pendingOrders++;
        }
      }

      return {
        'totalSales': totalSales,
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'totalProducts': 25, // TODO: Implementar contagem real de produtos
      };
    } catch (e) {
      AppLogger.error('Erro ao calcular métricas do dashboard', e);
      // Retornar valores padrão em caso de erro
      return {
        'totalSales': 0.0,
        'totalOrders': 0,
        'pendingOrders': 0,
        'totalProducts': 0,
      };
    }
  }

  @override
  Future<List<OrderModel>> getRecentOrders() async {
    try {
      AppLogger.info('📊 [METRICS] Buscando pedidos recentes reais...');

      // Buscar todos os pedidos do vendedor
      final allOrders = await _orderRepository.getVendorOrders();

      // Ordenar por data de criação (mais recentes primeiro)
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Retornar apenas os 4 mais recentes
      final recentOrders = allOrders.take(4).toList();

      AppLogger.info(
          '📊 [METRICS] ${recentOrders.length} pedidos recentes encontrados');

      return recentOrders;
    } catch (e) {
      AppLogger.error('Erro ao buscar pedidos recentes', e);
      return [];
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      AppLogger.info('📊 [METRICS] Buscando todos os pedidos...');

      // Buscar todos os pedidos do vendedor
      final allOrders = await _orderRepository.getVendorOrders();

      // Ordenar por data de criação (mais recentes primeiro)
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      AppLogger.info('📊 [METRICS] ${allOrders.length} pedidos encontrados');

      return allOrders;
    } catch (e) {
      AppLogger.error('Erro ao buscar todos os pedidos', e);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopProducts() async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 300));

    return [
      {
        'name': 'Maçã Fuji',
        'sales': 45,
        'revenue': 400.50,
      },
      {
        'name': 'Leite Integral',
        'sales': 32,
        'revenue': 220.80,
      },
      {
        'name': 'Pão Francês',
        'sales': 28,
        'revenue': 98.00,
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getSalesReport(
      {DateTime? startDate, DateTime? endDate}) async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 800));

    final start = startDate ?? DateTime.now().subtract(Duration(days: 30));
    final end = endDate ?? DateTime.now();

    return {
      'period': {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      },
      'totalSales': 3450.75,
      'totalOrders': 127,
      'averageOrderValue': 27.17,
      'topCategories': [
        {'name': 'Frutas e Verduras', 'sales': 45.2},
        {'name': 'Laticínios', 'sales': 28.7},
        {'name': 'Bebidas', 'sales': 26.1},
      ],
      'dailySales': [
        {'date': '2024-01-01', 'sales': 125.50},
        {'date': '2024-01-02', 'sales': 98.30},
        {'date': '2024-01-03', 'sales': 156.80},
      ],
    };
  }
}
