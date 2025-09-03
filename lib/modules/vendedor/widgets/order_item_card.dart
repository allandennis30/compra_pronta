import 'package:flutter/material.dart';
import '../controllers/order_builder_controller.dart';
import '../../../core/themes/app_colors.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemStatus itemStatus;
  final VoidCallback? onTap;
  final VoidCallback? onManualAdd;
  final VoidCallback? onManualRemove;

  const OrderItemCard({
    super.key,
    required this.itemStatus,
    this.onTap,
    this.onManualAdd,
    this.onManualRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isScanned = itemStatus.isScanned;
    final isComplete = itemStatus.isComplete;
    final item = itemStatus.orderItem;
    final progress = itemStatus.progress;

    // Cores baseadas no status usando o sistema reativo
    Color cardColor;
    Color borderColor;
    Color textColor;
    
    if (isComplete) {
      // Verde quando completo
      cardColor = AppColors.success(context).withOpacity(0.15);
      borderColor = AppColors.success(context);
      textColor = AppColors.success(context);
    } else if (isScanned) {
      // Azul quando parcialmente escaneado
      cardColor = AppColors.statusConfirmed(context).withOpacity(0.1);
      borderColor = AppColors.statusConfirmed(context);
      textColor = AppColors.statusConfirmed(context);
    } else {
      // Cinza quando não escaneado
      cardColor = AppColors.surface(context);
      borderColor = AppColors.border(context).withOpacity(0.3);
      textColor = AppColors.onSurface(context);
    }

    return Card(
      elevation: isComplete ? 4 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: isComplete ? 3 : (isScanned ? 2 : 1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cardColor,
          ),
          child: Row(
            children: [
              // Ícone de status
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isComplete
                      ? theme.colorScheme.primary
                      : isScanned
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        isComplete
                            ? Icons.check_circle
                            : isScanned
                                ? Icons.hourglass_empty
                                : Icons.shopping_bag_outlined,
                        color: isComplete || isScanned
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 24,
                      ),
                    ),
                    if (isScanned && !isComplete)
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Informações do produto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          itemStatus.product?.isSoldByWeight == true
                              ? 'Peso: ${(itemStatus.scannedQuantity / 10.0).toStringAsFixed(1)}kg/${(item.quantity / 10.0).toStringAsFixed(1)}kg'
                              : 'Qtd: ${itemStatus.scannedQuantity}/${item.quantity}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isComplete
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        Text(
                          itemStatus.product?.isSoldByWeight == true
                              ? 'R\$ ${(itemStatus.product?.pricePerKg ?? 0.0).toStringAsFixed(2)}/kg'
                              : 'R\$ ${item.price.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    if (isScanned) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ESCANEADO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Valor total e botão manual
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    itemStatus.product?.isSoldByWeight == true
                        ? 'R\$ ${((itemStatus.product?.pricePerKg ?? 0.0) * (item.quantity / 10.0)).toStringAsFixed(2)}'
                        : 'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isScanned
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Botões de controle manual
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de remover
                      if (onManualRemove != null && isScanned)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            onPressed: onManualRemove,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                              foregroundColor: theme.colorScheme.error,
                              padding: EdgeInsets.zero,
                            ),
                            tooltip: 'Remover manualmente',
                          ),
                        ),
                      if (onManualRemove != null && isScanned && onManualAdd != null && !isComplete)
                        const SizedBox(width: 4),
                      // Botão de adicionar
                      if (onManualAdd != null && !isComplete)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            onPressed: onManualAdd,
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              foregroundColor: theme.colorScheme.primary,
                              padding: EdgeInsets.zero,
                            ),
                            tooltip: 'Adicionar manualmente',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
