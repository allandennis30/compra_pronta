import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../core/constants/app_constants.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _productImage,
            const SizedBox(width: 12),
            _productInfo,
            _quantityControls,
          ],
        ),
      ),
    );
  }

  Widget get _productImage => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.product.imageUrl,
          width: isDesktop ? 80 : (isTablet ? 70 : 60),
          height: isDesktop ? 80 : (isTablet ? 70 : 60),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: isDesktop ? 80 : (isTablet ? 70 : 60),
              height: isDesktop ? 80 : (isTablet ? 70 : 60),
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: isDesktop ? 80 : (isTablet ? 70 : 60),
              height: isDesktop ? 80 : (isTablet ? 70 : 60),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey[600],
                size: isDesktop ? 30 : 24,
              ),
            );
          },
        ),
      );

  Widget get _productInfo => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.product.isSoldByWeight
                  ? 'R\$ ${item.product.pricePerKg?.toStringAsFixed(2) ?? '0.00'}/kg'
                  : 'R\$ ${item.product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppConstants.successColor),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isTablet || isDesktop) ...[
              const SizedBox(height: 4),
              Text(
                item.product.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );

  Widget get _quantityControls => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _quantityButtons,
          const SizedBox(height: 8),
          Obx(() {
            final cartItem = controller.items.firstWhere(
              (cartItem) => cartItem.product.id == item.product.id,
              orElse: () => item,
            );
            return Text(
              'R\$ ${cartItem.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.successColor),
              ),
            );
          }),
        ],
      );

  Widget get _quantityButtons {
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
              icon: Icons.remove,
              onPressed: () => controller.updateQuantity(
                  item.product.id, 
                  item.product.isSoldByWeight 
                      ? cartItem.quantity - 1 // Decrementa 0.1kg
                      : cartItem.quantity - 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
              icon: Icons.add,
              onPressed: () => controller.updateQuantity(
                  item.product.id, 
                  item.product.isSoldByWeight 
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
          backgroundColor: Colors.grey[200],
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.all(8),
        ),
      );
    }
  }
}
