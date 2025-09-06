import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../core/widgets/product_image_display.dart';
import '../../../core/themes/app_colors.dart';

class CartItemWidget extends GetView<CartController> {
  final dynamic item;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/cliente/produto', arguments: item.product);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _productImage,
                const SizedBox(width: 12),
                _productInfo(context),
                _quantityControls(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _productImage => ProductImageDisplay(
        imageUrl: item.product.imageUrl,
        width: isDesktop ? 80 : (isTablet ? 70 : 60),
        height: isDesktop ? 80 : (isTablet ? 70 : 60),
        borderRadius: BorderRadius.circular(8),
      );

  Widget _productInfo(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.product.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              (item.product.isSoldByWeight ?? false)
                  ? 'R\$ ${item.product.pricePerKg?.toStringAsFixed(2) ?? '0.00'}/kg'
                  : 'R\$ ${item.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.success(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isTablet || isDesktop) ...[
              const SizedBox(height: 4),
              Text(
                item.product.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );

  Widget _quantityControls(BuildContext context) => GestureDetector(
        onTap: () {
          // Para a propagação do evento para evitar navegação
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _quantityButtons(context),
            const SizedBox(height: 8),
            Obx(() {
              final cartItem = controller.items.firstWhere(
                (cartItem) => cartItem.product.id == item.product.id,
                orElse: () => item,
              );
              return Text(
                'R\$ ${cartItem.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success(context),
                ),
              );
            }),
          ],
        ),
      );

  Widget _quantityButtons(BuildContext context) {
    return Obx(() {
      final cartItem = controller.items.firstWhere(
        (cartItem) => cartItem.product.id == item.product.id,
        orElse: () => item,
      );

      if (isDesktop || isTablet) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuantityButton(
              context: context,
              icon: Icons.remove,
              onPressed: () => controller.updateQuantity(
                  item.product.id,
                  (item.product.isSoldByWeight ?? false)
                      ? cartItem.quantity - 1 // Decrementa 0.1kg
                      : cartItem.quantity - 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                (item.product.isSoldByWeight ?? false)
                    ? '${cartItem.displayQuantity.toStringAsFixed(1)}kg'
                    : '${cartItem.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildQuantityButton(
              context: context,
              icon: Icons.add,
              onPressed: () => controller.updateQuantity(
                  item.product.id,
                  (item.product.isSoldByWeight ?? false)
                      ? cartItem.quantity + 1 // Incrementa 0.1kg
                      : cartItem.quantity + 1),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuantityButton(
              context: context,
              icon: Icons.remove,
              onPressed: () => controller.updateQuantity(
                  item.product.id,
                  item.product.isSoldByWeight
                      ? cartItem.quantity - 1 // Decrementa 0.1kg
                      : cartItem.quantity - 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                item.product.isSoldByWeight
                    ? '${cartItem.displayQuantity.toStringAsFixed(1)}kg'
                    : '${cartItem.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildQuantityButton(
              context: context,
              icon: Icons.add,
              onPressed: () => controller.updateQuantity(
                  item.product.id,
                  item.product.isSoldByWeight
                      ? cartItem.quantity + 1 // Incrementa 0.1kg
                      : cartItem.quantity + 1),
            ),
          ],
        );
      }
    });
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    if (isDesktop) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Icon(icon, size: 16),
      );
    } else {
      return IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant(context),
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.all(8),
        ),
      );
    }
  }
}
