import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../widgets/client_bottom_nav.dart';

class ProductListPage extends StatelessWidget {
  final ProductListController controller = Get.put(ProductListController());

  ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.toNamed('/cliente/carrinho'),
            tooltip: 'Carrinho',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildActiveFiltersIndicator(),
          _buildFiltersPanel(),
          _buildCategoryFilter(),
          Expanded(
            child: _buildProductList(),
          ),
          _buildPaginationInfo(),
        ],
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 0),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
          Obx(() => IconButton(
                icon: Icon(
                  controller.showFilters
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  color: controller.hasActiveFilters ? Colors.blue : null,
                ),
                onPressed: controller.toggleFilters,
                tooltip: 'Filtros Avançados',
              )),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersIndicator() {
    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox.shrink();

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
                '${controller.filteredProductsCount} produto(s) encontrado(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
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

  Widget _buildFiltersPanel() {
    return Obx(() {
      if (!controller.showFilters) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
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

            // Filtro por Vendedor
            _buildVendorFilter(),
            const SizedBox(height: 16),

            // Filtro por Preço
            _buildPriceFilter(),
            const SizedBox(height: 16),

            // Filtro por Ordenação
            _buildSortingFilter(),
          ],
        ),
      );
    });
  }

  Widget _buildVendorFilter() {
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

  Widget _buildPriceFilter() {
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

  Widget _buildSortingFilter() {
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

  Widget _buildCategoryFilter() {
    return Obx(() {
      final categories = controller.categories;

      if (categories.isEmpty) {
        return const SizedBox(
          height: 50,
          child: Center(
            child: Text('Carregando categorias...'),
          ),
        );
      }

      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Obx(() {
                final isSelected = controller.isCategorySelected(category);

                return FilterChip(
                  label: Text(category.isEmpty ? 'Todos' : category),
                  selected: isSelected,
                  onSelected: (_) => controller.setCategory(category),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue[800],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue[800] : Colors.grey[800],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }),
            );
          },
        ),
      );
    });
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.isLoading && !controller.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty && controller.isInitialized) {
        return const Center(
          child: Text('Nenhum produto encontrado'),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshProducts,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Carregar mais produtos quando chegar próximo ao fim
            if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200 &&
                controller.hasNextPage &&
                !controller.isLoadingMore &&
                !controller.hasReachedEnd) {
              controller.loadNextPage();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.products.length + (controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.products.length) {
                // Indicador de carregamento no fim da lista
                return _buildLoadingIndicator();
              }

              final product = controller.products[index];
              return _buildProductCard(product, context);
            },
          ),
        ),
      );
    });
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Carregando mais produtos...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationInfo() {
    return Obx(() {
      if (controller.totalPages <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${controller.totalItems} produtos',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductCard(ProductModel product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: product.imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    product.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.shopping_bag,
                        color: Colors.grey.shade600,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.shopping_bag,
                  color: Colors.grey.shade600,
                ),
        ),
        title: Text(
          product.name ?? 'Produto sem nome',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.description != null)
              Text(
                product.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (product.category != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  'R\$ ${(product.price ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () {
            // Adicionar ao carrinho
            final cartController = Get.find<CartController>();
            cartController.addItem(product, context: context);
          },
        ),
      ),
    );
  }
}
