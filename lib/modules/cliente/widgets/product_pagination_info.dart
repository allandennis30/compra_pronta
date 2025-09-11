import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';

class ProductPaginationInfo extends StatelessWidget {
  const ProductPaginationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();
    
    return Obx(() {
      if (controller.products.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mostrando ${controller.products.length} produtos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (controller.hasNextPage && !controller.hasReachedEnd)
              Text(
                'Carregue mais rolando para baixo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (controller.hasReachedEnd && controller.products.isNotEmpty)
              Text(
                'Todos os produtos carregados',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      );
    });
  }
}