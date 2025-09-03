import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';

import '../../../core/widgets/product_image_display.dart';
import '../../../core/themes/app_colors.dart';

class ProductListPage extends StatelessWidget {
  final ProductListController controller = Get.put(ProductListController());

  ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildActiveFiltersIndicator(context),
          _buildFiltersPanel(context),
          _buildCategoryFilter(),
          Expanded(
            child: _buildProductGrid(context),
          ),
          _buildPaginationInfo(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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
                  color: controller.hasActiveFilters ? AppColors.primary(context) : null,
                ),
                onPressed: controller.toggleFilters,
                tooltip: 'Filtros Avançados',
              )),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersIndicator(BuildContext context) {
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

  Widget _buildFiltersPanel(BuildContext context) {
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
                  backgroundColor: AppColors.chipBackground(context),
                  selectedColor: AppColors.chipSelected(context).withOpacity(0.2),
                  checkmarkColor: AppColors.chipSelected(context),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.chipSelected(context) : AppColors.chipText(context),
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
                        child: Obx(() {
                          final cartController = Get.find<CartController>();
                          final isInCart = cartController.isProductInCart(product.id ?? '');
                          
                          return FilledButton.icon(
                            onPressed: isInCart ? null : () {
                              cartController.addItem(product, context: context);
                            },
                            icon: Icon(
                              isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                              size: 16,
                              color: isInCart ? const Color(0xFF2E7D32) : null,
                            ),
                            label: Text(
                              isInCart ? 'Adicionado' : 'Adicionar',
                              style: TextStyle(
                                fontSize: 13,
                                color: isInCart ? const Color(0xFF2E7D32) : null,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              backgroundColor: isInCart 
                                ? Colors.grey.shade200 // Cinza claro
                                : null,
                              foregroundColor: isInCart 
                                ? const Color(0xFF2E7D32) // Verde escuro
                                : null,
                            ),
                          );
                        }),
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

  Widget _buildProductGrid(BuildContext context) {
    return Obx(() {
      if (controller.isLoading && !controller.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty && controller.isInitialized) {
        return _buildEmptyState(context);
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

  Widget _buildPaginationInfo(BuildContext context) {
    return Obx(() {
      if (controller.totalPages <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
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
                color: AppColors.onSurfaceVariant(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: AppColors.iconSecondary(context)),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.onSurface(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar seus filtros ou palavras-chave.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant(context),
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
