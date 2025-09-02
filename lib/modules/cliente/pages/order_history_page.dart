import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_history_controller.dart';
import '../../../core/models/order_model.dart';

import '../../../core/utils/logger.dart';

class OrderHistoryPage extends StatelessWidget {
  final OrderHistoryController controller = Get.put(OrderHistoryController());

  OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum pedido encontrado',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça seu primeiro pedido para ver o histórico aqui',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
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
    final theme = Theme.of(context);

    if (order.items.isNotEmpty) {
      AppLogger.info('   - Primeiros itens:');
      for (int i = 0; i < order.items.take(3).length; i++) {
        final item = order.items[i];
        AppLogger.info(
            '     ${i + 1}. ${item.productName} (${item.quantity}x)');
      }
    } else {
      AppLogger.warning(
          '⚠️ [ORDER_CARD] NENHUM ITEM NO CARD DO PEDIDO ${order.id}!');
    }

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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'R\$ ${order.total.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              'Data: ${_formatDate(order.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (order.items.isNotEmpty)
              Text(
                '${order.items.take(2).map((item) => item.productName).join(', ')}${order.items.length > 2 ? '...' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itens do Pedido:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${item.quantity}x',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'R\$ ${order.subtotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Taxa de entrega:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'R\$ ${order.deliveryFee.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${order.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
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

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'dinheiro':
        return 'Dinheiro';
      case 'pix':
        return 'PIX';
      case 'cartao_credito':
        return 'Cartão de Crédito';
      case 'cartao_debito':
        return 'Cartão de Débito';
      default:
        return method;
    }
  }

  void _showOrderDetails(OrderModel order) {
    final theme = Theme.of(Get.context!);

    // Logs detalhados do pedido
    AppLogger.info('🔍 [ORDER_DETAILS] Abrindo detalhes do pedido:');
    AppLogger.info('   - ID: ${order.id}');
    AppLogger.info('   - Status: ${order.status}');
    AppLogger.info('   - Total: R\$ ${order.total}');
    AppLogger.info('   - Subtotal: R\$ ${order.subtotal}');
    AppLogger.info('   - Taxa de Entrega: R\$ ${order.deliveryFee}');
    AppLogger.info('   - Data de Criação: ${order.createdAt}');
    AppLogger.info('   - Data de Entrega: ${order.deliveredAt}');
    AppLogger.info('   - Previsão de Entrega: ${order.estimatedDeliveryTime}');
    AppLogger.info('   - Método de Pagamento: ${order.paymentMethod}');
    AppLogger.info('   - Instruções de Entrega: ${order.deliveryInstructions}');
    AppLogger.info('   - Notas: ${order.notes}');

    // Logs do endereço
    AppLogger.info('📍 [ORDER_DETAILS] Endereço de entrega:');
    AppLogger.info('   - Rua: ${order.deliveryAddress.street}');
    AppLogger.info('   - Número: ${order.deliveryAddress.number}');
    AppLogger.info('   - Complemento: ${order.deliveryAddress.complement}');
    AppLogger.info('   - Bairro: ${order.deliveryAddress.neighborhood}');
    AppLogger.info('   - Cidade: ${order.deliveryAddress.city}');
    AppLogger.info('   - Estado: ${order.deliveryAddress.state}');
    AppLogger.info('   - CEP: ${order.deliveryAddress.zipCode}');

    // Logs dos itens
    AppLogger.info(
        '🛒 [ORDER_DETAILS] Itens do pedido (${order.items.length} itens):');
    for (int i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      AppLogger.info('   ${i + 1}. ${item.productName}');
      AppLogger.info('      - ID: ${item.productId}');
      AppLogger.info('      - Preço: R\$ ${item.price}');
      AppLogger.info('      - Quantidade: ${item.quantity}');
      AppLogger.info('      - Total: R\$ ${item.price * item.quantity}');
    }

    if (order.items.isEmpty) {
      AppLogger.warning('⚠️ [ORDER_DETAILS] NENHUM ITEM ENCONTRADO NO PEDIDO!');
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pedido #${order.id}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      iconSize: 24,
                    ),
                  ],
                ),
              ),

              // Content with scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and dates
                      _buildInfoSection(
                        theme,
                        'Informações Gerais',
                        [
                          _buildInfoRow('Status',
                              controller.getStatusText(order.status), theme),
                          _buildInfoRow('Data do Pedido',
                              _formatDate(order.createdAt), theme),
                          if (order.deliveredAt != null)
                            _buildInfoRow('Entregue em',
                                _formatDate(order.deliveredAt!), theme),
                          if (order.estimatedDeliveryTime != null)
                            _buildInfoRow(
                                'Previsão de Entrega',
                                _formatDate(order.estimatedDeliveryTime!),
                                theme),
                          if (order.paymentMethod != null)
                            _buildInfoRow(
                                'Método de Pagamento',
                                _getPaymentMethodLabel(order.paymentMethod!),
                                theme),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Items
                      _buildInfoSection(
                        theme,
                        'Itens do Pedido (${order.items.length} item${order.items.length > 1 ? 's' : ''})',
                        order.items.isNotEmpty
                            ? order.items
                                .map((item) => _buildItemRow(item, theme))
                                .toList()
                            : [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Nenhum item encontrado',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                      ),

                      const SizedBox(height: 20),

                      // Address
                      _buildInfoSection(
                        theme,
                        'Endereço de Entrega',
                        [
                          _buildInfoRow(
                              'Rua',
                              '${order.deliveryAddress.street}, ${order.deliveryAddress.number}',
                              theme),
                          if (order.deliveryAddress.complement != null)
                            _buildInfoRow('Complemento',
                                order.deliveryAddress.complement!, theme),
                          _buildInfoRow('Bairro',
                              order.deliveryAddress.neighborhood, theme),
                          _buildInfoRow(
                              'Cidade',
                              '${order.deliveryAddress.city} - ${order.deliveryAddress.state}',
                              theme),
                          _buildInfoRow(
                              'CEP', order.deliveryAddress.zipCode, theme),
                        ],
                      ),

                      if (order.deliveryInstructions != null &&
                          order.deliveryInstructions!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildInfoSection(
                          theme,
                          'Instruções de Entrega',
                          [
                            _buildInfoRow('Instruções',
                                order.deliveryInstructions!, theme),
                          ],
                        ),
                      ],

                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildInfoSection(
                          theme,
                          'Observações',
                          [
                            _buildInfoRow('Notas', order.notes!, theme),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Values
                      _buildInfoSection(
                        theme,
                        'Valores',
                        [
                          _buildInfoRow(
                              'Subtotal',
                              'R\$ ${order.subtotal.toStringAsFixed(2)}',
                              theme),
                          _buildInfoRow(
                              'Taxa de Entrega',
                              'R\$ ${order.deliveryFee.toStringAsFixed(2)}',
                              theme),
                          _buildInfoRow('Total',
                              'R\$ ${order.total.toStringAsFixed(2)}', theme,
                              isTotal: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Fechar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.isNotEmpty
                      ? item.productName
                      : 'Produto não identificado',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'R\$ ${item.price.toStringAsFixed(2)} cada',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.quantity}x',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
