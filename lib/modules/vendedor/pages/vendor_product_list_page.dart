import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_product_list_controller.dart';
import 'vendor_product_form_page.dart';
import '../bindings/vendedor_product_form_binding.dart';
import '../widgets/product_card.dart';
import '../../cliente/models/product_model.dart';

class VendorProductListPage extends GetView<VendedorProductListController> {
  const VendorProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: controller.isSearching.value
                ? _buildSearchField()
                : const Text('Meus Produtos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: Icon(
                    controller.isSearching.value ? Icons.close : Icons.search),
                onPressed: controller.toggleSearch,
              ),
            ],
          ),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildFilterIndicator(),
                    Expanded(
                      child: controller.products.isEmpty
                          ? _buildEmptyState()
                          : _buildProductList(),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToProductForm(),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ));
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Buscar produtos...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: controller.searchProducts,
    );
  }

  Widget _buildFilterIndicator() {
    return Obx(() {
      final hasFilters = controller.searchQuery.value.isNotEmpty ||
          controller.selectedCategory.value.isNotEmpty;

      if (!hasFilters) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.blue.shade50,
        child: Row(
          children: [
            Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getFilterText(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: controller.clearFilters,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Limpar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    });
  }

  String _getFilterText() {
    final filters = <String>[];

    if (controller.searchQuery.value.isNotEmpty) {
      filters.add('Busca: "${controller.searchQuery.value}"');
    }

    if (controller.selectedCategory.value.isNotEmpty) {
      filters.add('Categoria: ${controller.selectedCategory.value}');
    }

    final resultText = '${controller.products.length} produto(s) encontrado(s)';

    return '${filters.join(' • ')} • $resultText';
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filtrar Produtos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtrar por categoria:'),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Categoria',
                  ),
                  value: controller.selectedCategory.value.isEmpty
                      ? null
                      : controller.selectedCategory.value,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todas as categorias'),
                    ),
                    ...controller.availableCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    controller.filterByCategory(value);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Get.back();
            },
            child: const Text('Limpar Filtros'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
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
            size: 80,
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
            'Clique no botão + para adicionar um produto',
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
    final result = await Get.to(
      () => const VendorProductFormPage(),
      binding: VendedorProductFormBinding(),
      arguments: product,
    );

    if (result == true) {
      // Recarregar produtos e mostrar mensagem de sucesso
      await controller.loadProducts();
      Get.snackbar(
        'Sucesso',
        product != null
            ? 'Produto atualizado com sucesso!'
            : 'Produto cadastrado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _toggleProductStatus(ProductModel product) {
    // Implementar lógica para alternar status do produto
    // Por enquanto, apenas mostra um snackbar
    Get.snackbar(
      'Status do Produto',
      (product.isAvailable ?? false)
          ? 'Produto ${product.name ?? 'Produto sem nome'} foi desativado'
          : 'Produto ${product.name ?? 'Produto sem nome'} foi ativado',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
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
