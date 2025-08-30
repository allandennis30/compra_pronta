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
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) => Obx(() {
        if (controller.isLoading) {
          return _loadingWidget;
        }

        if (controller.product == null) {
          return _errorWidget(context);
        }

        return _content(context);
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

  Widget _errorWidget(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Produto não encontrado',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'O produto que você está procurando\nnão está disponível no momento.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
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

  Widget _content(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            // Compact Product Image Section
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ProductImageWidget(
                imageUrl: controller.product!.imageUrl ?? '',
                productName: controller.product!.name ?? 'Produto sem nome',
                onShare: controller.shareProduct,
              ),
            ),
            // Compact Product Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ProductInfoWidget(
                product: controller.product!,
              ),
            ),
            // Compact Quantity Selector Section
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.15),
                ),
              ),
              child: Obx(() => QuantitySelectorWidget(
                    quantity: controller.quantity,
                    maxQuantity: controller.product!.stock ?? 0,
                    onIncrement: controller.incrementQuantity,
                    onDecrement: controller.decrementQuantity,
                    totalPrice: controller.totalPrice,
                    canAddToCart: controller.canAddToCart,
                    onAddToCart: () => controller.addToCart(context),
                    onGoToCart: controller.goToCart,
                    isSoldByWeight: controller.product!.isSoldByWeight ?? false,
                    weight: controller.weight,
                  )),
            ),
            // Minimal bottom padding
            const SizedBox(height: 8),
          ],
        ),
      );
}
