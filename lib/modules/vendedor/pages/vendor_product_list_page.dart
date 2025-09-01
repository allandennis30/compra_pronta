import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_product_list_controller.dart';
import '../../cliente/models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/vendedor_layout.dart';

class VendorProductListPage extends GetView<VendedorProductListController> {
  const VendorProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VendedorLayout(
      currentIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Produtos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToProductForm(),
              tooltip: 'Adicionar Produto',
            ),
          ],
        ),
        body: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildFilters(),
                  Expanded(
                    child: controller.products.isEmpty
                        ? _buildEmptyState()
                        : _buildProductList(),
                  ),
                ],
              )),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            decoration: InputDecoration(
              hintText: 'Buscar produtos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                    label: const Text('Todas'),
                    selected: controller.selectedCategory.value.isEmpty,
                    onSelected: (selected) {
                      if (selected) controller.clearFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: controller.selectedCategory.value == category,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece adicionando seu primeiro produto',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToProductForm(),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Produto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
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
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o produto "${product.name ?? 'Produto sem nome'}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteProduct(product.id ?? '');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
