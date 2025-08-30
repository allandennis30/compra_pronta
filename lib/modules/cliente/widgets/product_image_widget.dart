import 'package:flutter/material.dart';
import '../../../core/widgets/product_image_display.dart';

class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final VoidCallback? onShare;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    required this.productName,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ProductImageDisplay(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(16),
    );
  }
}
