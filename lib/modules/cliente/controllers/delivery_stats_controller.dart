import 'package:get/get.dart';
import '../../../utils/logger.dart';

class DeliveryStatsController extends GetxController {

  // Estado das estatísticas
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;

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
    loadStats();
  }

  /// Carrega as estatísticas do entregador
  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Simular dados de estatísticas (substituir por chamada real da API)
      await Future.delayed(const Duration(seconds: 1));
      
      // Dados mockados - substituir por dados reais da API
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
      
    } catch (e) {
      error.value = 'Erro ao carregar estatísticas: $e';
      AppLogger.error('Erro ao carregar estatísticas: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza as estatísticas
  Future<void> refreshStats() async {
    await loadStats();
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