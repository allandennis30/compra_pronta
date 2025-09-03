import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_product_list_controller.dart';
import '../../cliente/models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/vendedor_layout.dart';
import '../../../core/themes/app_colors.dart';

class VendorProductListPage extends GetView<VendedorProductListController> {
  const VendorProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VendedorLayout(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Meus Produtos'),
          backgroundColor: AppColors.appBarBackground(context),
          foregroundColor: AppColors.appBarForeground(context),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToProductForm(),
              tooltip: 'Adicionar Produto',
            ),
          ],
        ),
        body: Obx(() => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.loadingIndicator(context),
                ),
              )
            : Column(
                children: [
                  _buildFilters(context),
                  Expanded(
                    child: controller.products.isEmpty
                        ? _buildEmptyState(context)
                        : _buildProductList(),
                  ),
                ],
              )),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: controller.searchProducts,
            style: TextStyle(color: AppColors.onSurface(context)),
            decoration: InputDecoration(
              hintText: 'Buscar produtos...',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant(context)),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.iconSecondary(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderFocused(context)),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final categories = controller.availableCategories;
            if (categories.isEmpty) return const SizedBox.shrink();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      'Todas',
                      style: TextStyle(
                        color: controller.selectedCategory.value.isEmpty
                            ? Colors.white
                            : AppColors.chipText(context),
                      ),
                    ),
                    selected: controller.selectedCategory.value.isEmpty,
                    selectedColor: AppColors.chipSelected(context),
                    backgroundColor: AppColors.chipBackground(context),
                    onSelected: (selected) {
                      if (selected) controller.clearFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) {
                    final isSelected = controller.selectedCategory.value == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.chipText(context),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.chipSelected(context),
                        backgroundColor: AppColors.chipBackground(context),
                        onSelected: (selected) {
                          if (selected) {
                            controller.filterByCategory(category);
                          } else {
                            controller.clearFilters();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.iconSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece adicionando seu primeiro produto',
            style: TextStyle(
              color: AppColors.onSurfaceVariant(context),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToProductForm(),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Produto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary(context),
              foregroundColor: AppColors.buttonOnPrimary(context),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return ProductCard(
          product: product,
          onTap: () => _navigateToProductForm(product: product),
          onEdit: () => _navigateToProductForm(product: product),
          onToggleStatus: () => _toggleProductStatus(product),
          onDelete: () => _showDeleteConfirmation(product),
        );
      },
    );
  }

  void _navigateToProductForm({dynamic product}) async {
    final result = await Get.toNamed(
      '/vendor/produto_form',
      arguments: product,
    );

    if (result != null) {
      if (result is ProductModel) {
        // Atualizar apenas o produto específico na lista
        controller.updateProductInList(result);

        Get.snackbar(
          'Sucesso',
          'Produto atualizado com sucesso!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else if (result == true) {
        // Para produtos novos, recarregar toda a lista
        await controller.loadProducts();

        Get.snackbar(
          'Sucesso',
          'Produto criado com sucesso!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _toggleProductStatus(ProductModel product) async {
    try {
      await controller.toggleProductAvailability(product);
    } catch (e) {
      // O controller já trata os erros e mostra snackbars
    }
  }

  void _showDeleteConfirmation(ProductModel product) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface(Get.context!),
        title: Text(
          'Confirmar Exclusão',
          style: TextStyle(color: AppColors.onSurface(Get.context!)),
        ),
        content: Text(
          'Tem certeza que deseja excluir o produto "${product.name ?? 'Produto sem nome'}"?\n\n'
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: AppColors.onSurface(Get.context!)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.onSurface(Get.context!)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteProduct(product.id ?? '');
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error(Get.context!),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
