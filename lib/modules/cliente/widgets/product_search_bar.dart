import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../../../core/themes/app_colors.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: controller.setSearchQuery,
            ),
          ),
          const SizedBox(width: 8),
          /*  Obx(() => IconButton(
                icon: Icon(
                  controller.showFilters
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  color: controller.hasActiveFilters
                      ? AppColors.primary(context)
                      : null,
                ),
                onPressed: controller.toggleFilters,
                tooltip: 'Filtros Avançados',
              )), */
        ],
      ),
    );
  }
}
