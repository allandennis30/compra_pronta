import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_builder_controller.dart';

class OrderProgressHeader extends StatelessWidget {
  final OrderBuilderController controller;

  const OrderProgressHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final progress = controller.progress;
      final scannedCount = controller.scannedItemsCount;
      final totalCount = controller.totalItemsCount;

      return Container(
        padding: const EdgeInsets.all(16),
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
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: isDark
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progresso da Montagem',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Escaneie todos os itens',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.8)
                              : theme.colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.onPrimaryContainer.withOpacity(0.15)
                        : theme.colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$scannedCount/$totalCount',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDark
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Barra de progresso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.8)
                            : theme.colorScheme.onPrimary.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? theme.colorScheme.onPrimaryContainer.withOpacity(0.2)
                        : theme.colorScheme.onPrimary.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onPrimary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),

            if (controller.allItemsScanned) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.15)
                      : theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isDark
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pedido Completo!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isDark
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
