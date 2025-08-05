import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart';
import '../widgets/product_image_widget.dart';
import '../widgets/product_info_widget.dart';
import '../widgets/quantity_selector_widget.dart';

class ProductDetailPage extends GetView<ProductDetailController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.product?.name ?? 'Detalhes do Produto',
          style: const TextStyle(fontWeight: FontWeight.w600),
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareProduct,
          ),
        ],
      ),
      body: _body,
      bottomNavigationBar: _bottomNavigationBar,
    );
  }



  Widget get _body => Obx(() {
        if (controller.isLoading) {
          return _loadingWidget;
        }

        if (controller.product == null) {
          return _errorWidget;
        }

        return _content;
      });

  Widget get _loadingWidget => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Carregando produto...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );

  Widget get _errorWidget => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Produto não encontrado',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'O produto que você está procurando\nnão está disponível no momento.',
                textAlign: TextAlign.center,
                style: Theme.of(Get.context!).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Voltar às compras'),
              ),
            ],
          ),
        ),
      );

  Widget get _content => SingleChildScrollView(
        child: Column(
          children: [
            // Product Image Section
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ProductImageWidget(
                imageUrl: controller.product!.imageUrl,
                productName: controller.product!.name,
                onShare: controller.shareProduct,
              ),
            ),
            // Product Info Section
            Obx(() => ProductInfoWidget(
                  product: controller.product!,
                  isFavorite: controller.isFavorite,
                  onToggleFavorite: controller.toggleFavorite,
                )),
            const SizedBox(height: 120), // Space for bottom navigation bar
          ],
        ),
      );

  Widget get _bottomNavigationBar => Obx(() {
        if (controller.product == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: QuantitySelectorWidget(
              quantity: controller.quantity,
              maxQuantity: controller.product!.stock,
              onIncrement: controller.incrementQuantity,
              onDecrement: controller.decrementQuantity,
              totalPrice: controller.totalPrice,
              canAddToCart: controller.canAddToCart,
              onAddToCart: controller.addToCart,
              onGoToCart: controller.goToCart,
            ),
          ),
        );
      });
}