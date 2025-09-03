import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/vendor_metrics_controller.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VendorMetricsController controller;

  const OrderCard({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.toNamed('/vendor/pedido', arguments: order.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildOrderAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOrderInfo(context),
                ),
                const SizedBox(width: 12),
                _buildStatusChip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            controller.getStatusColor(order.status),
            controller.getStatusColor(order.status).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: controller.getStatusColor(order.status).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '#${order.id.split('_').last}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.clientName ?? 'Cliente não informado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.attach_money,
              size: 16,
              color: AppColors.success(context),
            ),
            Text(
              'R\$ ${order.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.success(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: AppColors.iconSecondary(context),
            ),
            const SizedBox(width: 4),
            Text(
              _getTimeAgo(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    final statusColor = controller.getStatusColor(order.status);
    final statusText = controller.getStatusText(order.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(order.createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';
    }
  }
}