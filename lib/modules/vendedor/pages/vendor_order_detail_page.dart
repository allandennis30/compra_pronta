import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_order_detail_controller.dart';

class VendorOrderDetailPage extends GetView<VendorOrderDetailController> {
  const VendorOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detalhes do Pedido',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Obx(() => controller.order != null
              ? IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: controller.shareOrderDetails,
                  tooltip: 'Compartilhar',
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando detalhes do pedido...'),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          );
        }

        if (controller.order == null) {
          return const Center(
            child: Text('Pedido não encontrado'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              const SizedBox(height: 16),
              _buildCustomerInfo(),
              const SizedBox(height: 16),
              _buildDeliveryAddress(),
              const SizedBox(height: 16),
              _buildOrderItems(),
              const SizedBox(height: 16),
              _buildOrderSummary(),
              const SizedBox(height: 16),
              _buildStatusSection(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderHeader() {
    final order = controller.order!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${order.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                       controller.formatDateTime(order.createdAt),
                       style: TextStyle(
                         fontSize: 14,
                         color: Colors.grey.shade600,
                       ),
                     ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: controller.getStatusColor(order.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    controller.getStatusDisplayName(order.status),
                    style: TextStyle(
                      color: controller.getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (order.deliveredAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                     'Entregue em ${controller.formatDateTime(order.deliveredAt!)}',
                     style: TextStyle(
                       color: Colors.green.shade700,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final customer = controller.customer;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Informações do Cliente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customer != null) ...[
              _buildInfoRow('Nome', customer.name),
              _buildInfoRow('Email', customer.email),
              _buildInfoRow('Telefone', customer.phone),
            ] else
              const Text(
                'Informações do cliente não disponíveis',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    final address = controller.order!.deliveryAddress;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Endereço de Entrega',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                address.fullAddress,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    final items = controller.order!.items;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Itens do Pedido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qtd: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final order = controller.order!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: Colors.purple.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resumo do Pedido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', 'R\$ ${order.subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Taxa de Entrega', 'R\$ ${order.deliveryFee.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              'R\$ ${order.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final order = controller.order!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.update,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Atualizar Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Status atual: ${controller.getStatusDisplayName(order.status)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableStatuses
                  .where((status) => status != order.status)
                  .map((status) => _buildStatusChip(status))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Obx(() => ActionChip(
          label: Text(
            controller.getStatusDisplayName(status),
            style: TextStyle(
              color: controller.getStatusColor(status),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          backgroundColor: controller.getStatusColor(status).withOpacity(0.1),
          side: BorderSide(
            color: controller.getStatusColor(status),
            width: 1,
          ),
          onPressed: controller.isUpdatingStatus
              ? null
              : () => _showStatusConfirmation(status),
        ));
  }

  void _showStatusConfirmation(String newStatus) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Alteração'),
        content: Text(
          'Deseja alterar o status do pedido para "${controller.getStatusDisplayName(newStatus)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateOrderStatus(newStatus);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}