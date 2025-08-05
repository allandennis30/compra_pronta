import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_history_controller.dart';
import '../../../core/models/order_model.dart';

class OrderHistoryPage extends StatelessWidget {
  final OrderHistoryController controller = Get.put(OrderHistoryController());

  OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshOrders,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum pedido encontrado',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Faça seu primeiro pedido para ver o histórico aqui',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(context, order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'R\$ ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: controller.getStatusColor(order.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                controller.getStatusText(order.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Data: ${_formatDate(order.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Itens do Pedido:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.productName),
                          ),
                          Text('${item.quantity}x'),
                          const SizedBox(width: 16),
                          Text(
                              'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('R\$ ${order.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Taxa de entrega:'),
                    Text('R\$ ${order.deliveryFee.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'R\$ ${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.repeatOrder(order.id, context),
                        child: const Text('Repetir Pedido'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showOrderDetails(order),
                        child: const Text('Ver Detalhes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showOrderDetails(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text('Detalhes do Pedido #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${controller.getStatusText(order.status)}'),
              Text('Data: ${_formatDate(order.createdAt)}'),
              if (order.deliveredAt != null)
                Text('Entregue em: ${_formatDate(order.deliveredAt!)}'),
              const SizedBox(height: 16),
              const Text('Endereço de Entrega:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  '${order.deliveryAddress.street}, ${order.deliveryAddress.number}'),
              if (order.deliveryAddress.complement != null)
                Text('Complemento: ${order.deliveryAddress.complement}'),
              Text(
                  '${order.deliveryAddress.neighborhood}, ${order.deliveryAddress.city} - ${order.deliveryAddress.state}'),
              Text('CEP: ${order.deliveryAddress.zipCode}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
