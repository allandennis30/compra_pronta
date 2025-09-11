import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../../../core/themes/app_colors.dart';

class ProductFiltersPanel extends StatelessWidget {
  const ProductFiltersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();
    
    return Obx(() {
      if (!controller.showFilters) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros Avançados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.toggleFilters,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _VendorFilter(),
            const SizedBox(height: 16),
            const _PriceFilter(),
            const SizedBox(height: 16),
            const _SortingFilter(),
          ],
        ),
      );
    });
  }
}

class _VendorFilter extends StatelessWidget {
  const _VendorFilter();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vendedor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedVendor.isEmpty
                  ? null
                  : controller.selectedVendor,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos os vendedores'),
                ),
                ...controller.vendors.where((v) => v.isNotEmpty).map((vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor,
                    child: Text(vendor),
                  );
                }),
              ],
              onChanged: (value) {
                controller.setVendor(value ?? '');
              },
            )),
      ],
    );
  }
}

class _PriceFilter extends StatelessWidget {
  const _PriceFilter();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Faixa de Preço',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mín',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0.0;
                  controller.setPriceRange(price, controller.maxPrice);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Máx',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 1000.0;
                  controller.setPriceRange(controller.minPrice, price);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SortingFilter extends StatelessWidget {
  const _SortingFilter();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ordenar por',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.sortBy,
              items: controller.sortOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final ascending = value == 'name' || value == 'price';
                  controller.setSorting(value, ascending: ascending);
                }
              },
            )),
      ],
    );
  }
}