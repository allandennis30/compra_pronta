import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/delivery_stats_model.dart';

class DailySummaryWidget extends StatelessWidget {
  final DeliveryStatsModel stats;
  final bool isLoading;
  final VoidCallback? onViewDetails;

  const DailySummaryWidget({
    super.key,
    required this.stats,
    this.isLoading = false,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumo do Dia',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: Text(
                      'Ver Detalhes',
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDailyProgress(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Entregas',
                    stats.deliveriesToday.toString(),
                    Icons.local_shipping,
                    Get.theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Ganhos',
                    'R\$ ${stats.totalEarnings.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Distância',
                    '${_calculateDistance().toStringAsFixed(1)} km',
                    Icons.route,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Tempo Online',
                    _formatOnlineTime(),
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (stats.deliveriesToday > 0) ...[
              const SizedBox(height: 16),
              _buildPerformanceIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumo do Dia',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            Text(
              'Carregando resumo...',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgress() {
    final progress = _calculateDailyProgress();
    final progressColor = _getProgressColor(progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso Diário',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Get.theme.colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
        const SizedBox(height: 4),
        Text(
          _getProgressMessage(progress),
          style: Get.textTheme.bodySmall?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator() {
    final performance = _getPerformanceLevel();
    final color = _getPerformanceColor(performance);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getPerformanceIcon(performance),
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance: $performance',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  _getPerformanceMessage(performance),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDailyProgress() {
    // Meta diária de 10 entregas
    const dailyGoal = 10;
    return (stats.deliveriesToday / dailyGoal * 100).clamp(0, 100);
  }

  double _calculateDistance() {
    // Estimativa baseada no número de entregas
    return stats.deliveriesToday * 3.5; // 3.5km por entrega em média
  }

  String _formatOnlineTime() {
    // Simulação de tempo online baseado nas entregas
    final hours = (stats.deliveriesToday * 0.5).clamp(0, 12);
    return '${hours.toStringAsFixed(1)}h';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) {
      return Colors.green;
    } else if (progress >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getProgressMessage(double progress) {
    if (progress >= 100) {
      return 'Meta diária alcançada! Parabéns!';
    } else if (progress >= 80) {
      return 'Quase lá! Continue assim.';
    } else if (progress >= 50) {
      return 'Bom progresso, mantenha o ritmo.';
    } else {
      return 'Ainda há tempo para mais entregas.';
    }
  }

  String _getPerformanceLevel() {
    final rate = stats.successRate;
    if (rate >= 95) {
      return 'Excelente';
    } else if (rate >= 85) {
      return 'Muito Bom';
    } else if (rate >= 70) {
      return 'Bom';
    } else {
      return 'Precisa Melhorar';
    }
  }

  Color _getPerformanceColor(String performance) {
    switch (performance) {
      case 'Excelente':
        return Colors.green;
      case 'Muito Bom':
        return Colors.lightGreen;
      case 'Bom':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData _getPerformanceIcon(String performance) {
    switch (performance) {
      case 'Excelente':
        return Icons.star;
      case 'Muito Bom':
        return Icons.thumb_up;
      case 'Bom':
        return Icons.trending_up;
      default:
        return Icons.warning;
    }
  }

  String _getPerformanceMessage(String performance) {
    switch (performance) {
      case 'Excelente':
        return 'Você está indo muito bem!';
      case 'Muito Bom':
        return 'Ótimo trabalho hoje!';
      case 'Bom':
        return 'Continue melhorando!';
      default:
        return 'Foque na qualidade das entregas.';
    }
  }
}