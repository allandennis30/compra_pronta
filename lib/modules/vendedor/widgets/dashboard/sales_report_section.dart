import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sales_report_controller.dart';
import '../../../../core/themes/app_colors.dart';
import 'package:intl/intl.dart';

class SalesReportSection extends StatelessWidget {
  final SalesReportController controller;

  const SalesReportSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildPeriodSelector(context),
            const SizedBox(height: 16),
            _buildStats(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  color: AppColors.primary(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Relatórios de Vendas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface(context),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período do Relatório',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface(context),
              ),
        ),
        const SizedBox(height: 8),
        _buildPredefinedPeriods(context),
        const SizedBox(height: 12),
        _buildCustomPeriod(context),
      ],
    );
  }

  Widget _buildPredefinedPeriods(BuildContext context) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.predefinedPeriods.map((period) {
        final isSelected = controller.selectedPeriod == period['label'];
        return GestureDetector(
          onTap: () => controller.selectPredefinedPeriod(period['label']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                ? AppColors.primary(context) 
                : AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                  ? AppColors.primary(context) 
                  : AppColors.border(context),
              ),
            ),
            child: Text(
              period['label'],
              style: TextStyle(
                color: isSelected 
                  ? Colors.white 
                  : AppColors.onSurfaceVariant(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildCustomPeriod(BuildContext context) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildDateField(
            context,
            label: 'Data Inicial',
            date: controller.startDate,
            onTap: () => _selectDate(context, true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            context,
            label: 'Data Final',
            date: controller.endDate,
            onTap: () => _selectDate(context, false),
          ),
        ),
      ],
    ));
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Selecionar',
              style: TextStyle(
                fontSize: 14,
                color: date != null 
                  ? AppColors.onSurface(context) 
                  : AppColors.onSurfaceVariant(context),
                fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Obx(() {
      final stats = controller.getPeriodStats();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Pedidos',
                  stats['totalOrders'].toString(),
                  Icons.shopping_bag_outlined,
                ),
                _buildStatItem(
                  context,
                  'Receita',
                  controller.formatCurrency(stats['totalRevenue']),
                  Icons.attach_money,
                ),
                _buildStatItem(
                  context,
                  'Itens',
                  stats['totalItems'].toString(),
                  Icons.inventory_2_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(
                  context,
                  'Ticket Médio',
                  controller.formatCurrency(stats['averageOrderValue']),
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary(context),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.isGeneratingPdf ? null : controller.previewReport,
            icon: controller.isGeneratingPdf 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.visibility_outlined),
            label: Text(controller.isGeneratingPdf ? 'Gerando...' : 'Visualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.isGeneratingPdf ? null : controller.generateAndShareReport,
            icon: controller.isGeneratingPdf 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.share_outlined),
            label: Text(controller.isGeneratingPdf ? 'Gerando...' : 'Compartilhar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary(context),
              side: BorderSide(color: AppColors.primary(context)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final currentDate = isStartDate ? controller.startDate : controller.endDate;
    final initialDate = currentDate ?? DateTime.now();
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (selectedDate != null) {
      if (isStartDate) {
        controller.setCustomPeriod(selectedDate, controller.endDate ?? DateTime.now());
      } else {
        controller.setCustomPeriod(controller.startDate ?? DateTime.now().subtract(const Duration(days: 30)), selectedDate);
      }
    }
  }
}
