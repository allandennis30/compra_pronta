import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/order_model.dart';

class DeliveryCard extends StatelessWidget {
  final OrderModel delivery;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final bool showAcceptButton;
  final bool showStatusBadge;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.onAccept,
    this.showAcceptButton = false,
    this.showStatusBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDeliveryInfo(),
              const SizedBox(height: 12),
              _buildLocationInfo(),
              if (showAcceptButton) ...[
                const SizedBox(height: 16),
                _buildActionButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#${delivery.id}',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        if (showStatusBadge) _buildStatusBadge(),
        const SizedBox(width: 8),
        Text(
          'R\$ ${delivery.total.toStringAsFixed(2)}',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Get.theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final statusInfo = _getStatusInfo(delivery.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo['color'],
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'],
            size: 12,
            color: statusInfo['color'],
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo['text'],
            style: Get.textTheme.bodySmall?.copyWith(
              color: statusInfo['color'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          _formatDateTime(delivery.createdAt),
          style: Get.textTheme.bodySmall?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.payment,
          size: 16,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          delivery.paymentMethod ?? 'Não informado',
          style: Get.textTheme.bodySmall?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: Get.theme.primaryColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            delivery.deliveryAddress.toString(),
            style: Get.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Get.theme.dividerColor,
            ),
          ),
          child: Text(
            '2.5km', // Placeholder distance
            style: Get.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAccept,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('Aceitar Entrega'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'text': 'Pendente',
          'icon': Icons.schedule,
          'color': Colors.orange,
        };
      case 'accepted':
        return {
          'text': 'Aceita',
          'icon': Icons.check_circle_outline,
          'color': Colors.blue,
        };
      case 'in_progress':
        return {
          'text': 'Em Andamento',
          'icon': Icons.local_shipping,
          'color': Get.theme.primaryColor,
        };
      case 'delivered':
        return {
          'text': 'Entregue',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case 'cancelled':
        return {
          'text': 'Cancelada',
          'icon': Icons.cancel,
          'color': Colors.red,
        };
      default:
        return {
          'text': 'Desconhecido',
          'icon': Icons.help_outline,
          'color': Get.theme.colorScheme.onSurface,
        };
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    }
  }
}