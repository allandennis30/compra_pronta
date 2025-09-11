import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../../../core/themes/app_colors.dart';

class ProductActiveFiltersIndicator extends StatelessWidget {
  const ProductActiveFiltersIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();
    
    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.highlight(context),
        child: Row(
          children: [
            Icon(Icons.filter_alt, size: 16, color: AppColors.primary(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${controller.filteredProductsCount} produto(s) encontrado(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: controller.clearAllFilters,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child:
                  const Text('Limpar Filtros', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    });
  }
}