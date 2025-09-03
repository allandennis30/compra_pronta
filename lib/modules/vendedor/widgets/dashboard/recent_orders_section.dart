import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/vendor_metrics_controller.dart';
import 'order_card.dart';
import '../../../../core/themes/app_colors.dart';

class RecentOrdersSection extends StatelessWidget {
  final VendorMetricsController controller;

  const RecentOrdersSection({
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
            _buildOrdersList(),
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
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pedidos Recentes',
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
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => Get.toNamed('/vendor/pedidos'),
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          label: const Text(
            'Ver Todos',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary(context),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      if (controller.recentOrders.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = controller.recentOrders[index];
          return OrderCard(order: order, controller: controller);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.iconSecondary(Get.context!),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum pedido recente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface(Get.context!),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Os pedidos aparecerão aqui quando chegarem',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant(Get.context!),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
