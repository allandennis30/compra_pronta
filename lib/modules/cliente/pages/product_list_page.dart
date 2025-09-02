import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';

import '../../../core/widgets/product_image_display.dart';

class ProductListPage extends StatelessWidget {
  final ProductListController controller = Get.put(ProductListController());

  ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          _buildCartIcon(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildActiveFiltersIndicator(),
          _buildFiltersPanel(),
          _buildCategoryFilter(),
          Expanded(
            child: _buildProductGrid(),
          ),
          _buildPaginationInfo(),
        ],
      ),
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

  Widget _buildProductCard(ProductModel product, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/cliente/produto', arguments: product);
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do produto
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        ProductCardImageDisplay(
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // Categoria no canto superior direito
                        if (product.category != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                product.category!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Informações do produto
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do produto
                      Text(
                        product.name ?? 'Produto sem nome',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      const Spacer(),

                      const SizedBox(height: 6),

                      // Preço
                      Text(
                        'R\$ ${(product.price ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Botão de adicionar ao carrinho
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: FilledButton.icon(
                          onPressed: () {
                            final cartController = Get.find<CartController>();
                            cartController.addItem(product, context: context);
                          },
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            size: 16,
                          ),
                          label: const Text(
                            'Adicionar',
                            style: TextStyle(fontSize: 15),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading && !controller.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty && controller.isInitialized) {
        return _buildEmptyState();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determinar o número de colunas baseado na largura da tela
              int crossAxisCount = 3; // Padrão: 3 itens
              double childAspectRatio = 0.55; // Cards mais compactos
              double spacing = 8.0;

              if (constraints.maxWidth > 1200) {
                // Desktop grande: 5 colunas
                crossAxisCount = 5;
                childAspectRatio = 0.6;
                spacing = 12.0;
              } else if (constraints.maxWidth > 900) {
                // Desktop médio: 4 colunas
                crossAxisCount = 4;
                childAspectRatio = 0.55;
                spacing = 10.0;
              } else if (constraints.maxWidth > 600) {
                // Tablet: 3 colunas
                crossAxisCount = 3;
                childAspectRatio = 0.55;
                spacing = 8.0;
              } else if (constraints.maxWidth > 400) {
                // Mobile grande: 3 colunas
                crossAxisCount = 3;
                childAspectRatio = 0.5;
                spacing = 6.0;
              } else {
                // Mobile pequeno: 2 colunas
                crossAxisCount = 2;
                childAspectRatio = 0.55;
                spacing = 6.0;
              }

              return GridView.builder(
                padding: EdgeInsets.all(spacing + 4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: controller.products.length +
                    (controller.isLoadingMore ? crossAxisCount : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.products.length) {
                    // Indicador de carregamento no fim da lista
                    return _buildLoadingCard();
                  }

                  final product = controller.products[index];
                  return _buildProductCard(product, context);
                },
              );
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

  Widget _buildCartIcon() {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final itemCount = cartController.itemCount;

      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.toNamed('/cliente/carrinho'),
            tooltip: 'Carrinho',
          ),
          if (itemCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar seus filtros ou palavras-chave.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
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
}
