import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_builder_controller.dart';
import '../controllers/vendor_scan_controller.dart';
import '../widgets/order_item_card.dart';
import '../widgets/barcode_scanner.dart';

class OrderBuilderPage extends StatelessWidget {
  const OrderBuilderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderController = Get.put(OrderBuilderController());
    final scanController = Get.put(VendorScanController());
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.colorScheme.background : theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Montagem do Pedido',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Pedido #${orderController.currentOrder.id}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor:
            isDark ? theme.colorScheme.surface : theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: isDark ? 1 : 0,
        shadowColor: isDark ? theme.colorScheme.shadow.withOpacity(0.1) : null,
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: orderController.allItemsScanned
                      ? () => _showCompletionDialog(context, orderController)
                      : null,
                  icon: Icon(
                    Icons.check_circle,
                    color: orderController.allItemsScanned
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  tooltip: orderController.allItemsScanned
                      ? 'Finalizar pedido'
                      : 'Escaneie todos os itens',
                ),
              )),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Scanner de código de barras - otimizado
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surface
                      : theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark
                      ? Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        )
                      : null,
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 300, // Aumentado para melhor visualização
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BarcodeScanner(
                          onBarcodeDetected: (barcode) {
                            orderController.processScannedBarcode(barcode);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Lista de itens do pedido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Itens do Pedido',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${orderController.scannedItemsCount}/${orderController.totalItemsCount}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Obx(() {
                        if (orderController.orderItems.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum item encontrado',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12,
                              66), // Padding bottom para não sobrepor o progresso
                          itemCount: orderController.orderItems.length,
                          itemBuilder: (context, index) {
                            final itemStatus =
                                orderController.orderItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OrderItemCard(
                                itemStatus: itemStatus,
                                onTap: () =>
                                    _showItemDetails(context, itemStatus),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Container suspenso com progresso no final da página
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isDark
                    ? null
                    : LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isDark ? theme.colorScheme.primaryContainer : null,
                borderRadius: BorderRadius.circular(12),
                border: isDark
                    ? Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(() {
                final progress = orderController.progress;
                final scannedCount = orderController.scannedItemsCount;
                final totalCount = orderController.totalItemsCount;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        color: isDark
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Progresso: $scannedCount/$totalCount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: isDark
                                    ? theme.colorScheme.onPrimaryContainer
                                        .withOpacity(0.2)
                                    : theme.colorScheme.onPrimary
                                        .withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onPrimary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (orderController.allItemsScanned)
                        Icon(
                          Icons.check_circle,
                          color: isDark
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onPrimary,
                          size: 20,
                        )
                      else
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, OrderItemStatus itemStatus) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: itemStatus.isScanned
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemStatus.orderItem.productName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        itemStatus.isScanned ? 'ESCANEADO' : 'PENDENTE',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: itemStatus.isScanned
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              context,
              'Quantidade',
              '${itemStatus.orderItem.quantity} unidades',
              Icons.inventory_2_outlined,
            ),
            _buildDetailRow(
              context,
              'Preço Unitário',
              'R\$ ${itemStatus.orderItem.price.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            _buildDetailRow(
              context,
              'Total',
              'R\$ ${(itemStatus.orderItem.price * itemStatus.orderItem.quantity).toStringAsFixed(2)}',
              Icons.calculate,
            ),
            if (itemStatus.product != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produto Escaneado',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Código: ${itemStatus.product!.barcode}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(
      BuildContext context, OrderBuilderController controller) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Pedido Completo!'),
          ],
        ),
        content: const Text(
          'Todos os itens foram escaneados com sucesso. O pedido está pronto para ser finalizado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.back();
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
