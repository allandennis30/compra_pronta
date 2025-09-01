import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_order_detail_controller.dart';

class VendorOrderDetailPage extends GetView<VendorOrderDetailController> {
  const VendorOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detalhes do Pedido',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          tooltip: 'Voltar',
        ),
        actions: [
          Obx(() => controller.order != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.refreshOrder,
                      tooltip: 'Atualizar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: controller.shareOrderDetails,
                      tooltip: 'Compartilhar',
                    ),
                  ],
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Carregando detalhes do pedido...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
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
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.error,
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
          return Center(
            child: Text(
              'Pedido não encontrado',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(context),
                    const SizedBox(height: 16),
                    _buildCustomerAndDeliveryInfo(context),
                    const SizedBox(height: 16),
                    _buildOrderItems(context),
                    const SizedBox(height: 16),
                    _buildOrderSummary(context),
                    const SizedBox(height: 16),
                    _buildStatusSection(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context),
          ],
        );
      }),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    final order = controller.order!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Pedido #${order.id.substring(0, 8)}...',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: controller
                            .getStatusColor(order.status)
                            .withOpacity(0.1),
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
                const SizedBox(height: 4),
                Text(
                  'ID completo: ${order.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formatDateTime(order.createdAt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Entregue em ${controller.formatDateTime(order.deliveredAt!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCustomerAndDeliveryInfo(BuildContext context) {
    final customer = controller.customer;
    final address = controller.order!.deliveryAddress;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Debug: verificar se o endereço está chegando
    print('🔍 [VENDOR_ORDER_DETAIL] Endereço: ${address.fullAddress}');
    print('🔍 [VENDOR_ORDER_DETAIL] Street: ${address.street}');
    print('🔍 [VENDOR_ORDER_DETAIL] Number: ${address.number}');
    print('🔍 [VENDOR_ORDER_DETAIL] Neighborhood: ${address.neighborhood}');
    print('🔍 [VENDOR_ORDER_DETAIL] City: ${address.city}');
    print('🔍 [VENDOR_ORDER_DETAIL] State: ${address.state}');
    print('🔍 [VENDOR_ORDER_DETAIL] ZipCode: ${address.zipCode}');
    print('🔍 [VENDOR_ORDER_DETAIL] Complement: ${address.complement}');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Informações do Cliente
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informações do Cliente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customer != null) ...[
              _buildInfoRow('Nome', customer.name, context),
              _buildInfoRow('Email', customer.email, context),
              _buildInfoRow('Telefone', customer.phone, context),
            ] else
              Text(
                'Informações do cliente não disponíveis',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

            // Divisor
            const SizedBox(height: 24),
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(height: 16),

            // Seção de Endereço de Entrega
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Endereço de Entrega',
                  style: theme.textTheme.titleMedium?.copyWith(
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
                color: isDark
                    ? theme.colorScheme.surface.withOpacity(0.5)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address.street.isNotEmpty)
                    Text(
                      address.street,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (address.number.isNotEmpty)
                    Text(
                      'Número: ${address.number}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  if (address.neighborhood.isNotEmpty)
                    Text(
                      'Bairro: ${address.neighborhood}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  if (address.city.isNotEmpty || address.state.isNotEmpty)
                    Text(
                      '${address.city}${address.city.isNotEmpty && address.state.isNotEmpty ? ' - ' : ''}${address.state}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  if (address.zipCode.isNotEmpty)
                    Text(
                      'CEP: ${address.zipCode}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  if (address.street.isEmpty && address.city.isEmpty)
                    Text(
                      'Endereço não informado',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    final items = controller.order!.items;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Itens do Pedido',
                  style: theme.textTheme.titleMedium?.copyWith(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surface.withOpacity(0.5)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qtd: ${item.quantity}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${item.price.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToOrderBuilder(context),
                icon: const Icon(Icons.qr_code),
                label: const Text('Montar Pedido'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final order = controller.order!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumo do Pedido',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal',
                'R\$ ${order.subtotal.toStringAsFixed(2)}', context),
            _buildSummaryRow('Taxa de Entrega',
                'R\$ ${order.deliveryFee.toStringAsFixed(2)}', context),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              'R\$ ${order.total.toStringAsFixed(2)}',
              context,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final order = controller.order!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.update,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Atualizar Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Status atual: ${controller.getStatusDisplayName(order.status)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
    final theme = Theme.of(Get.context!);

    Get.dialog(
      AlertDialog(
        title: Text(
          'Confirmar Alteração',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Deseja alterar o status do pedido para "${controller.getStatusDisplayName(newStatus)}"?',
          style: theme.textTheme.bodyMedium,
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

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, BuildContext context,
      {bool isTotal = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderBuilder(BuildContext context) {
    Get.toNamed(
      '/vendor/order-builder',
      arguments: {
        'order': controller.order,
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.goBack(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToOrderBuilder(context),
              icon: const Icon(Icons.edit),
              label: const Text('Editar Pedido'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
