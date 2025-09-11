import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../../../core/themes/app_colors.dart';

class ProductCategoryFilter extends StatelessWidget {
  const ProductCategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();

    return Obx(() {
      final categories = controller.categories;

      if (categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'Carregando categorias...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context),
          border: Border(
            bottom: BorderSide(
              color: AppColors.border(context),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Obx(() {
                      final isSelected =
                          controller.isCategorySelected(category);

                      return FilterChip(
                        label: Text(category.isEmpty ? 'Todos' : category),
                        selected: isSelected,
                        onSelected: (_) => controller.setCategory(category),
                        backgroundColor: AppColors.chipBackground(context),
                        selectedColor:
                            AppColors.chipSelected(context).withOpacity(0.2),
                        checkmarkColor: AppColors.chipSelected(context),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.chipSelected(context)
                              : AppColors.chipText(context),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        elevation: isSelected ? 2 : 0,
                        pressElevation: 4,
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
