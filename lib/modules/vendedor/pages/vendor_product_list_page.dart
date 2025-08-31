import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_product_list_controller.dart';
import '../widgets/product_card.dart';
import '../../cliente/models/product_model.dart';
import '../../../core/utils/logger.dart';

class VendorProductListPage extends GetView<VendedorProductListController> {
  const VendorProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _VendorProductListAppBar(controller: controller),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _FilterIndicator(controller: controller),
                Expanded(
                  child: controller.products.isEmpty
                      ? _EmptyState(controller: controller)
                      : _ProductListView(controller: controller),
                ),
              ],
            )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToProductForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToProductForm({dynamic product}) async {
    // Usar rota nomeada para evitar múltiplas instâncias
    final result = await Get.toNamed(
      '/vendor/produto_form',
      arguments: product,
    );

    if (result != null) {
      if (result is ProductModel) {
        // Produto foi editado - recarregar lista para mostrar a nova imagem
        AppLogger.info(
            '🔄 [LIST] Produto editado retornado, recarregando lista...');
        await controller.loadProducts();

        Get.snackbar(
          'Sucesso',
          'Produto atualizado com sucesso!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else if (result == true) {
        // Produto foi criado - recarregar lista completa
        AppLogger.info('🆕 [LIST] Novo produto criado, recarregando lista...');
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
}

class _VendorProductListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VendedorProductListController controller;

  const _VendorProductListAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppBar(
          title: controller.isSearching.value
              ? _SearchField(controller: controller)
              : const Text('Meus Produtos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
            IconButton(
              icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search),
              onPressed: controller.toggleSearch,
            ),
          ],
        ));
  }

  void _showFilterDialog(BuildContext context) {
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchField extends StatelessWidget {
  final VendedorProductListController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class _FilterIndicator extends StatelessWidget {
  final VendedorProductListController controller;

  const _FilterIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class _EmptyState extends StatelessWidget {
  final VendedorProductListController controller;

  const _EmptyState({required this.controller});

  @override
  Widget build(BuildContext context) {
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

  void _navigateToProductForm() async {
    final result = await Get.toNamed(
      '/vendor/produto_form',
      arguments: null,
    );

    if (result != null) {
      if (result is ProductModel) {
        AppLogger.info(
            '🔄 [LIST] Produto editado retornado, recarregando lista...');
        await controller.loadProducts();

        Get.snackbar(
          'Sucesso',
          'Produto atualizado com sucesso!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else if (result == true) {
        AppLogger.info('🆕 [LIST] Novo produto criado, recarregando lista...');
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
}

class _ProductListView extends StatelessWidget {
  final VendedorProductListController controller;

  const _ProductListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
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
        ));
  }

  void _navigateToProductForm({dynamic product}) async {
    final result = await Get.toNamed(
      '/vendor/produto_form',
      arguments: product,
    );

    if (result != null) {
      if (result is ProductModel) {
        AppLogger.info(
            '🔄 [LIST] Produto editado retornado, recarregando lista...');
        await controller.loadProducts();

        Get.snackbar(
          'Sucesso',
          'Produto atualizado com sucesso!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else if (result == true) {
        AppLogger.info('🆕 [LIST] Novo produto criado, recarregando lista...');
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
