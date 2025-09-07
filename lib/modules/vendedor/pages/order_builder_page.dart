import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_builder_controller.dart';
import '../widgets/order_item_card.dart';
import '../widgets/barcode_scanner.dart';

class OrderBuilderPage extends StatelessWidget {
  const OrderBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderController = Get.put(OrderBuilderController());
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.colorScheme.surface : theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
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
            Builder(
              builder: (context) {
                final order = orderController.currentOrder;
                if (order == null) {
                  return Text(
                    'Carregando...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  );
                }
                return Text(
                  order.clientName != null && order.clientName!.isNotEmpty
                      ? 'Pedido do ${order.clientName}'
                      : 'Pedido #${order.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                );
              },
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
         
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Botão para abrir/fechar leitor
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Obx(() {
                  final isScannerVisible =
                      orderController.isScannerVisible.value;
                  return ElevatedButton.icon(
                    onPressed: () => orderController.toggleScannerVisibility(),
                    icon: Icon(
                      isScannerVisible ? Icons.close : Icons.qr_code_scanner,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isScannerVisible ? 'Fechar Leitor' : 'Abrir Leitor',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isScannerVisible ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  );
                }),
              ),

              // Scanner de código de barras - condicional
              Obx(() {
                if (orderController.isScannerVisible.value) {
                  return Container(
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
                                color:
                                    theme.colorScheme.shadow.withOpacity(0.08),
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
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),

              Obx(() {
                if (orderController.isScannerVisible.value) {
                  return const SizedBox(height: 12);
                } else {
                  return const SizedBox.shrink();
                }
              }),

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
                          Obx(() {
                            final scannedCount =
                                orderController.scannedItemsCount;
                            final totalCount = orderController.totalItemsCount;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$scannedCount/$totalCount',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Obx(() {
                        final items = orderController.orderItems;
                        if (items.isEmpty) {
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
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final itemStatus = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OrderItemCard(
                                itemStatus: itemStatus,
                                onTap: () =>
                                    _showItemDetails(context, itemStatus),
                                onManualAdd: () => _addManually(itemStatus),
                                onManualRemove: () =>
                                    _removeManually(itemStatus),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
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
                    final detailedProgress = orderController.detailedProgress;
                    final scannedCount = orderController.scannedItemsCount;
                    final totalCount = orderController.totalItemsCount;
                    final items = orderController.orderItems;

                    final totalQuantityNeeded = items.fold(
                        0, (sum, item) => sum + item.orderItem.quantity);
                    final totalQuantityScanned = items.fold(
                        0, (sum, item) => sum + item.scannedQuantity);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                                  'Itens: $scannedCount/$totalCount • Qtd: $totalQuantityScanned/$totalQuantityNeeded',
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
                                    value: detailedProgress,
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
                              '${(detailedProgress * 100).toInt()}%',
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
                // Botão "Finalizar Pedido" visível quando todos os itens foram adicionados
                Obx(() {
                  final canFinish = orderController.allItemsScanned;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: canFinish
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showCompletionDialog(
                                  context, orderController),
                              icon: const Icon(Icons.check),
                              label: const Text('Finalizar Montagem do Pedido'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                }),
              ],
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
                    color: itemStatus.isComplete
                        ? theme.colorScheme.primary
                        : itemStatus.isScanned
                            ? theme.colorScheme.secondary
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
                        itemStatus.isComplete
                            ? 'COMPLETO'
                            : itemStatus.isScanned
                                ? 'PARCIAL'
                                : 'PENDENTE',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: itemStatus.isComplete
                              ? theme.colorScheme.primary
                              : itemStatus.isScanned
                                  ? theme.colorScheme.secondary
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
              itemStatus.product?.isSoldByWeight == true
                  ? 'Peso Necessário'
                  : 'Quantidade Necessária',
              itemStatus.product?.isSoldByWeight == true
                  ? '${(itemStatus.orderItem.quantity / 10.0).toStringAsFixed(1)} kg'
                  : '${itemStatus.orderItem.quantity} unidades',
              Icons.inventory_2_outlined,
            ),
            _buildDetailRow(
              context,
              itemStatus.product?.isSoldByWeight == true
                  ? 'Peso Escaneado'
                  : 'Quantidade Escaneada',
              itemStatus.product?.isSoldByWeight == true
                  ? '${(itemStatus.scannedQuantity / 10.0).toStringAsFixed(1)} kg'
                  : '${itemStatus.scannedQuantity} unidades',
              Icons.qr_code_scanner,
            ),
            _buildDetailRow(
              context,
              'Progresso',
              '${(itemStatus.progress * 100).toInt()}%',
              Icons.trending_up,
            ),
            _buildDetailRow(
              context,
              itemStatus.product?.isSoldByWeight == true
                  ? 'Preço por Kg'
                  : 'Preço Unitário',
              itemStatus.product?.isSoldByWeight == true
                  ? 'R\$ ${(itemStatus.product?.pricePerKg ?? 0.0).toStringAsFixed(2)}/kg'
                  : 'R\$ ${itemStatus.orderItem.price.toStringAsFixed(2)}',
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

  void _addManually(OrderItemStatus itemStatus) {
    final orderController = Get.find<OrderBuilderController>();

    // Verificar se o produto tem código de barras
    if (itemStatus.product?.barcode != null &&
        (itemStatus.product!.barcode ?? '').isNotEmpty) {
      // Processar o código de barras do produto
      orderController.processScannedBarcode(itemStatus.product!.barcode ?? '');
    } else {
      // Incrementar quantidade escaneada diretamente
      final currentItem = itemStatus;
      final newScannedQuantity = currentItem.scannedQuantity + 1;

      if (newScannedQuantity <= currentItem.orderItem.quantity) {
        final index = orderController.orderItems.indexWhere(
          (item) => item.orderItem.productId == currentItem.orderItem.productId,
        );

        if (index != -1) {
          orderController.orderItems[index] = currentItem.copyWith(
            isScanned: newScannedQuantity > 0,
            scannedQuantity: newScannedQuantity,
          );
          orderController.saveProgress();
        }
      }
    }
  }

  void _removeManually(OrderItemStatus itemStatus) {
    final orderController = Get.find<OrderBuilderController>();

    // Verificar se há quantidade para remover
    if (itemStatus.scannedQuantity > 0) {
      // Decrementar quantidade escaneada
      final currentItem = itemStatus;
      final newScannedQuantity = currentItem.scannedQuantity - 1;

      final index = orderController.orderItems.indexWhere(
        (item) => item.orderItem.productId == currentItem.orderItem.productId,
      );

      if (index != -1) {
        orderController.orderItems[index] = currentItem.copyWith(
          isScanned: newScannedQuantity > 0,
          scannedQuantity: newScannedQuantity,
        );
        orderController.saveProgress();
      }
    } else {
      Get.snackbar(
        'Aviso',
        'Não há quantidade escaneada para remover',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.tertiary,
        colorText: Get.theme.colorScheme.onTertiary,
        duration: const Duration(seconds: 2),
      );
    }
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
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Finalizar pedido e atualizar status
              await controller.finishOrder();
              
              // Navegar para a tela de pedidos do vendedor
              Get.offAllNamed('/vendor/pedidos');
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
