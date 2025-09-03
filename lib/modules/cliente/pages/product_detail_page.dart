import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart';
import '../widgets/product_image_widget.dart';
import '../widgets/product_info_widget.dart';

class ProductDetailPage extends GetView<ProductDetailController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _body(context),
      bottomNavigationBar: _buildFloatingBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() => IconButton(
                icon: Icon(
                  controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: controller.isFavorite 
                      ? Colors.red 
                      : Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => controller.toggleFavorite(context),
              )),
        ),
      ],
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

  Widget get _loadingWidget => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1),
              Theme.of(Get.context!).colorScheme.background,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Carregando produto...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );

  Widget _errorWidget(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.error.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Produto não encontrado',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'O produto que você está procurando\nnão está disponível no momento.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar às compras'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _content(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero Image Section
        SliverToBoxAdapter(
          child: _buildHeroImageSection(context),
        ),
        // Product Info Section
        SliverToBoxAdapter(
          child: _buildProductInfoSection(context),
        ),
        // Bottom spacing for floating bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 200),
        ),
      ],
    );
  }

  Widget _buildHeroImageSection(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            ProductImageWidget(
              imageUrl: controller.product!.imageUrl ?? '',
              productName: controller.product!.name ?? 'Produto sem nome',
            ),
            // Gradient overlay for better text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Product name overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Obx(() => Text(
                    controller.product?.name ?? 'Produto sem nome',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ProductInfoWidget(
        product: controller.product!,
      ),
    );
  }



  Widget _buildFloatingBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ver Carrinho Button (Full Width)
              _buildViewCartButton(context),
              const SizedBox(height: 12),
              // Main Action Section (Quantity + Total + Add)
              _buildMainActionSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.goToCart,
        icon: Icon(
          Icons.shopping_cart_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(
          'Ver Carrinho',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildMainActionSection(BuildContext context) {
    return Obx(() {
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            // Quantity Row
            Row(
              children: [
                // Quantity Label
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        controller.product!.isSoldByWeight ?? false ? Icons.scale : Icons.inventory_2,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.product!.isSoldByWeight ?? false ? 'Peso' : 'Quantidade',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                // Quantity Controls
                _buildCompactQuantityControls(context),
              ],
            ),
            const SizedBox(height: 16),
            // Total and Add Row
            Row(
              children: [
                // Total Display
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'R\$ ${controller.totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add to Cart Button
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 64, // Mesma altura do container do total (padding 12 + conteúdo)
                    child: FilledButton.icon(
                      onPressed: controller.canAddToCart ? () => controller.addToCart(context) : null,
                      icon: Icon(
                        controller.canAddToCart ? Icons.add_shopping_cart : Icons.block,
                        size: 20,
                      ),
                      label: Text(
                        controller.canAddToCart ? 'Adicionar' : 'Indisponível',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCompactQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCompactQuantityButton(
            context: context,
            icon: Icons.remove,
            onPressed: controller.product!.isSoldByWeight ?? false
                ? (controller.weight > 0.1 ? controller.decrementQuantity : null)
                : (controller.quantity > 1 ? controller.decrementQuantity : null),
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              controller.product!.isSoldByWeight ?? false
                  ? '${controller.weight.toStringAsFixed(1)}kg'
                  : controller.quantity.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          _buildCompactQuantityButton(
            context: context,
            icon: Icons.add,
            onPressed: controller.product!.isSoldByWeight ?? false
                ? controller.incrementQuantity
                : (controller.quantity < (controller.product!.stock ?? 0) ? controller.incrementQuantity : null),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactQuantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: onPressed != null
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }




}
