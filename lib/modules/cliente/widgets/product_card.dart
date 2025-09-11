import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../controllers/cart_controller.dart';
import '../../../core/widgets/product_image_display.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  
  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildProductImage(),
              _buildProductInfo(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Expanded(
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
              if (product.category != null) _buildCategoryBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Positioned(
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
    );
  }

  Widget _buildProductInfo(ThemeData theme) {
    return Expanded(
      flex: 6,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductName(theme),
            const SizedBox(height: 8),
            const Spacer(),
            const SizedBox(height: 6),
            _buildProductPrice(theme),
            const SizedBox(height: 2),
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductName(ThemeData theme) {
    return Text(
      product.name ?? 'Produto sem nome',
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductPrice(ThemeData theme) {
    return Text(
      'R\$ ${(product.price ?? 0).toStringAsFixed(2)}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: Obx(() {
        final cartController = Get.find<CartController>();
        final isInCart = cartController.isProductInCart(product.id ?? '');

        return FilledButton.icon(
          onPressed: isInCart
              ? null
              : () {
                  cartController.addItem(product, context: Get.context!);
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
            backgroundColor: isInCart ? Colors.grey.shade200 : null,
            foregroundColor: isInCart ? const Color(0xFF2E7D32) : null,
          ),
        );
      }),
    );
  }
}