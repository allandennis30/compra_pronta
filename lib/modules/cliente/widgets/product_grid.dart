import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductListController>();
    
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
              final gridConfig = _getGridConfiguration(constraints.maxWidth);
              
              return GridView.builder(
                padding: EdgeInsets.all(gridConfig.spacing),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridConfig.crossAxisCount,
                  childAspectRatio: gridConfig.childAspectRatio,
                  crossAxisSpacing: gridConfig.spacing,
                  mainAxisSpacing: gridConfig.spacing,
                ),
                itemCount: controller.products.length + 
                    (controller.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.products.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  final product = controller.products[index];
                  return ProductCard(product: product);
                },
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou buscar por outros termos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  _GridConfiguration _getGridConfiguration(double maxWidth) {
    if (maxWidth > 1200) {
      return _GridConfiguration(
        crossAxisCount: 5,
        childAspectRatio: 0.6,
        spacing: 12.0,
      );
    } else if (maxWidth > 900) {
      return _GridConfiguration(
        crossAxisCount: 4,
        childAspectRatio: 0.55,
        spacing: 10.0,
      );
    } else if (maxWidth > 600) {
      return _GridConfiguration(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        spacing: 8.0,
      );
    } else if (maxWidth > 400) {
      return _GridConfiguration(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
        spacing: 6.0,
      );
    } else {
      return _GridConfiguration(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        spacing: 6.0,
      );
    }
  }
}

class _GridConfiguration {
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  _GridConfiguration({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.spacing,
  });
}