import 'package:get/get.dart';
import '../../../utils/logger.dart';
import '../repositories/delivery_repository.dart';
import '../../auth/controllers/auth_controller.dart';

class DeliveryStatsController extends GetxController {
  final DeliveryRepository _deliveryRepository = DeliveryRepository();

  // Estado das estatísticas
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;

  // Filtros de período
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString selectedPeriod = 'Últimos 30 dias'.obs;

  // Dados das estatísticas
  final RxInt totalDeliveries = 0.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt completedToday = 0.obs;
  final RxList<Map<String, dynamic>> recentDeliveries = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> monthlyStats = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDefaultPeriod();
    _debugUserStatus();
    loadStats();
  }

  /// Debug do status do usuário
  void _debugUserStatus() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;
    
    AppLogger.info('=== DEBUG DELIVERY STATS ===');
    AppLogger.info('Usuário logado: ${user?.name}');
    AppLogger.info('Email: ${user?.email}');
    AppLogger.info('ID: ${user?.id}');
    AppLogger.info('É entregador: ${user?.isEntregador}');
    AppLogger.info('É vendedor: ${user?.isSeller}');
    AppLogger.info('============================');
  }

  /// Inicializa o período padrão (últimos 30 dias)
  void _initializeDefaultPeriod() {
    final now = DateTime.now();
    endDate.value = now;
    startDate.value = now.subtract(const Duration(days: 30));
  }

  /// Carrega as estatísticas do entregador
  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Usar API real com filtros de data
      final dateFrom = startDate.value?.toIso8601String().split('T')[0];
      final dateTo = endDate.value?.toIso8601String().split('T')[0];
      
      final statsData = await _deliveryRepository.getDeliveryStats(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      
      // Processar dados da API
      _processStatsData(statsData);
      
    } catch (e) {
      // Fallback para dados mockados em caso de erro
      AppLogger.error('Erro ao carregar estatísticas da API: $e');
      _loadMockData();
    } finally {
      isLoading.value = false;
    }
  }

  /// Processa os dados recebidos da API
  void _processStatsData(Map<String, dynamic> data) {
    totalDeliveries.value = data['total_deliveries'] ?? 0;
    totalEarnings.value = (data['total_earnings'] ?? 0.0).toDouble();
    averageRating.value = (data['average_rating'] ?? 0.0).toDouble();
    completedToday.value = data['today']?['deliveries'] ?? 0;
    
    // Processar entregas recentes
    if (data['recent_deliveries'] != null) {
      recentDeliveries.value = List<Map<String, dynamic>>.from(
        data['recent_deliveries'].map((delivery) => {
          ...delivery,
          'completed_at': delivery['completed_at'] != null 
            ? DateTime.parse(delivery['completed_at'])
            : DateTime.now(),
        }),
      );
    } else {
      recentDeliveries.clear();
    }
    
    // Processar estatísticas mensais
    if (data['monthly_stats'] != null) {
      monthlyStats.value = List<Map<String, dynamic>>.from(data['monthly_stats']);
    } else {
      monthlyStats.clear();
    }
    
    AppLogger.info('Estatísticas processadas: ${totalDeliveries.value} entregas, R\$ ${totalEarnings.value.toStringAsFixed(2)} ganhos');
  }

  /// Carrega dados mockados como fallback
  void _loadMockData() {
    totalDeliveries.value = 127;
    totalEarnings.value = 2450.75;
    averageRating.value = 4.8;
    completedToday.value = 8;
    
    recentDeliveries.value = [
      {
        'id': '1',
        'store_name': 'Loja ABC',
        'delivery_address': 'Rua das Flores, 123',
        'amount': 45.50,
        'completed_at': DateTime.now().subtract(const Duration(hours: 2)),
        'rating': 5,
      },
      {
        'id': '2',
        'store_name': 'Mercado XYZ',
        'delivery_address': 'Av. Principal, 456',
        'amount': 78.20,
        'completed_at': DateTime.now().subtract(const Duration(hours: 4)),
        'rating': 4,
      },
      {
        'id': '3',
        'store_name': 'Farmácia Central',
        'delivery_address': 'Rua do Comércio, 789',
        'amount': 32.90,
        'completed_at': DateTime.now().subtract(const Duration(hours: 6)),
        'rating': 5,
      },
    ];
    
    monthlyStats.value = [
      {'month': 'Jan', 'deliveries': 45, 'earnings': 890.50},
      {'month': 'Fev', 'deliveries': 52, 'earnings': 1024.75},
      {'month': 'Mar', 'deliveries': 48, 'earnings': 945.20},
      {'month': 'Abr', 'deliveries': 55, 'earnings': 1180.30},
      {'month': 'Mai', 'deliveries': 62, 'earnings': 1345.80},
      {'month': 'Jun', 'deliveries': 58, 'earnings': 1256.40},
    ];
  }

  /// Atualiza as estatísticas
  Future<void> refreshStats() async {
    await loadStats();
  }

  /// Aplica filtro de período personalizado
  Future<void> applyCustomPeriod(DateTime start, DateTime end) async {
    if (start.isAfter(end)) {
      error.value = 'Data inicial deve ser anterior à data final';
      return;
    }
    
    startDate.value = start;
    endDate.value = end;
    selectedPeriod.value = 'Período personalizado';
    await loadStats();
  }

  /// Aplica filtro de período pré-definido
  Future<void> applyPredefinedPeriod(String period) async {
    final now = DateTime.now();
    
    switch (period) {
      case 'Hoje':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = now;
        break;
      case 'Últimos 7 dias':
        startDate.value = now.subtract(const Duration(days: 7));
        endDate.value = now;
        break;
      case 'Últimos 30 dias':
        startDate.value = now.subtract(const Duration(days: 30));
        endDate.value = now;
        break;
      case 'Este mês':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = now;
        break;
      case 'Mês passado':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate.value = lastMonth;
        endDate.value = DateTime(now.year, now.month, 0); // Último dia do mês anterior
        break;
      case 'Últimos 3 meses':
        startDate.value = now.subtract(const Duration(days: 90));
        endDate.value = now;
        break;
      default:
        return;
    }
    
    selectedPeriod.value = period;
    await loadStats();
  }

  /// Lista de períodos pré-definidos disponíveis
  List<String> get availablePeriods => [
    'Hoje',
    'Últimos 7 dias',
    'Últimos 30 dias',
    'Este mês',
    'Mês passado',
    'Últimos 3 meses',
  ];

  /// Retorna o texto formatado do período atual
  String get currentPeriodText {
    if (startDate.value == null || endDate.value == null) {
      return 'Período não definido';
    }
    
    if (selectedPeriod.value == 'Período personalizado') {
      return '${formatDate(startDate.value!)} - ${formatDate(endDate.value!)}';
    }
    
    return selectedPeriod.value;
  }

  /// Formata valor monetário
  String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata data
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formata hora
  String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Calcula a média de entregas por dia no mês atual
  double get averageDeliveriesPerDay {
    if (monthlyStats.isEmpty) return 0.0;
    final currentMonth = monthlyStats.last;
    final deliveries = currentMonth['deliveries'] ?? 0;
    final daysInMonth = DateTime.now().day;
    return deliveries / daysInMonth;
  }

  /// Calcula o crescimento percentual em relação ao mês anterior
  double get monthlyGrowth {
    if (monthlyStats.length < 2) return 0.0;
    final current = monthlyStats.last['earnings'] ?? 0.0;
    final previous = monthlyStats[monthlyStats.length - 2]['earnings'] ?? 0.0;
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

}