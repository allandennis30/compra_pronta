import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../controllers/delivery_detail_controller.dart';

class DeliveryDetailPage extends GetView<DeliveryDetailController> {
  const DeliveryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Entrega'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadDeliveryDetails(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadDeliveryDetails(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (controller.delivery.value == null) {
          return const Center(
            child: Text('Entrega não encontrada'),
          );
        }

        final delivery = controller.delivery.value!;

        return RefreshIndicator(
          onRefresh: () async => controller.loadDeliveryDetails(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(delivery),
                const SizedBox(height: 16),
                _buildDeliveryInfo(delivery),
                const SizedBox(height: 16),
                _buildCustomerInfo(delivery),
                const SizedBox(height: 16),
                _buildItemsList(delivery),
                const SizedBox(height: 16),
                _buildLocationInfo(delivery),
                const SizedBox(height: 24),
                _buildActionButtons(delivery),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(OrderModel delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(delivery.status),
                  color: _getStatusColor(delivery.status),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status da Entrega',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(delivery.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(delivery.status),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(delivery.status),
                    color: _getStatusColor(delivery.status),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(delivery.status),
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: _getStatusColor(delivery.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (delivery.status == 'in_progress') ...[

              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: 0.6, // Placeholder progress
                backgroundColor: Get.theme.colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Get.theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entrega em andamento',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(OrderModel delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações da Entrega',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.receipt_outlined,
              'Pedido',
              '#${delivery.id}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.attach_money,
              'Valor Total',
              'R\$ ${delivery.total.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.payment,
              'Forma de Pagamento',
              delivery.paymentMethod ?? 'Não informado',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Horário do Pedido',
              _formatDateTime(delivery.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(OrderModel delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Cliente',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person,
              'Nome',
              'Cliente', // Placeholder name
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.phone,
              'Telefone',
              '(11) 99999-9999', // Placeholder phone
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text('Ligar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('Mensagem'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(OrderModel delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens do Pedido',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...delivery.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Get.theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${item.quantity}x R\$ ${item.price.toStringAsFixed(2)}',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'R\$ ${(item.quantity * item.price).toStringAsFixed(2)}',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(OrderModel delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Endereço de Entrega',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    delivery.deliveryAddress.toString(),
                    style: Get.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map),
                label: const Text('Abrir no Mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel delivery) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      switch (delivery.status) {
        case 'pending':
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.updateDeliveryStatus('accepted'),
                  child: const Text('Aceitar Entrega'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => controller.updateDeliveryStatus('cancelled'),
                  child: const Text('Recusar Entrega'),
                ),
              ),
            ],
          );
        case 'accepted':
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.updateDeliveryStatus('in_progress'),
              child: const Text('Iniciar Entrega'),
            ),
          );
        case 'in_progress':
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.updateDeliveryStatus('delivered'),
              child: const Text('Finalizar Entrega'),
            ),
          );
        case 'delivered':
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Entrega Finalizada',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Get.theme.primaryColor;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Get.theme.colorScheme.onSurface;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Aguardando Aceite';
      case 'accepted':
        return 'Aceita';
      case 'in_progress':
        return 'Em Andamento';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Status Desconhecido';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}