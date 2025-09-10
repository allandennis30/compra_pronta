import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../controllers/delivery_list_controller.dart';

class DeliveryListPage extends GetView<DeliveryListController> {
  const DeliveryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshDeliveries,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.deliveries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando entregas...'),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty && controller.deliveries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(controller.errorMessage),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadDeliveries,
                  child: Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDeliveries,
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: _buildDeliveryList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Get.theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.delivery_dining,
            color: Get.theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entregas Próximas',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Text(
                  '${controller.deliveries.length} entregas disponíveis',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                )),
              ],
            ),
          ),
          Obx(() => controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Todas'),
            selected: true,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Próximas'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Urgentes'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Alto Valor'),
            selected: false,
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryList() {
    return Obx(() {
      final deliveries = controller.deliveries;
      
      if (deliveries.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDeliveryCard(delivery),
          );
        },
      );
    });
  }

  Widget _buildDeliveryCard(OrderModel delivery) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Get.toNamed('/entregador/delivery/${delivery.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Text(
                    'R\$ ${delivery.total.toStringAsFixed(2)}',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
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
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '2.5km', // Placeholder distance
                    style: Get.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _showAcceptDialog(delivery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Aceitar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma entrega disponível',
            style: Get.textTheme.titleMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Novas entregas aparecerão aqui quando estiverem disponíveis',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshDeliveries,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(OrderModel delivery) {
    Get.dialog(
      AlertDialog(
        title: const Text('Aceitar Entrega'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja aceitar esta entrega?'),
            const SizedBox(height: 16),
            _buildDeliveryInfo(delivery),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.acceptDelivery(delivery);
            },
            child: const Text('Aceitar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(OrderModel delivery) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Get.theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  style: Get.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: Get.theme.colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                'R\$ ${delivery.total.toStringAsFixed(2)}',
                style: Get.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                size: 16,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDistance(2.5), // Placeholder distance
                style: Get.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }
}