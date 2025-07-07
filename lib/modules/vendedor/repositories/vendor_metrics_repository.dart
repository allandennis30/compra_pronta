abstract class VendorMetricsRepository {
  Future<Map<String, dynamic>> getDashboardMetrics();
  Future<List<Map<String, dynamic>>> getRecentOrders();
  Future<List<Map<String, dynamic>>> getTopProducts();
  Future<Map<String, dynamic>> getSalesReport({DateTime? startDate, DateTime? endDate});
}

class VendorMetricsRepositoryImpl implements VendorMetricsRepository {
  @override
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'totalSales': 1250.50,
      'totalOrders': 45,
      'pendingOrders': 8,
      'totalProducts': 25,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentOrders() async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 300));
    
    return [
      {
        'id': 'order_001',
        'customer': 'João Silva',
        'total': 89.90,
        'status': 'pending',
        'date': DateTime.now().subtract(Duration(hours: 2)),
      },
      {
        'id': 'order_002',
        'customer': 'Maria Santos',
        'total': 156.70,
        'status': 'confirmed',
        'date': DateTime.now().subtract(Duration(hours: 4)),
      },
      {
        'id': 'order_003',
        'customer': 'Pedro Costa',
        'total': 67.30,
        'status': 'delivered',
        'date': DateTime.now().subtract(Duration(days: 1)),
      },
    ];
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
  Future<Map<String, dynamic>> getSalesReport({DateTime? startDate, DateTime? endDate}) async {
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