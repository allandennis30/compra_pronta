import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductInfoWidget extends StatelessWidget {
  final ProductModel product;

  const ProductInfoWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header with name, price and favorite
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                   product.name,
                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                     fontWeight: FontWeight.bold,
                   ),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
                const SizedBox(height: 8),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: Theme.of(context).colorScheme.primaryContainer,
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Text(
                     product.category,
                     style: Theme.of(context).textTheme.labelSmall?.copyWith(
                       color: Theme.of(context).colorScheme.onPrimaryContainer,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.isSoldByWeight
                            ? 'R\$ ${product.pricePerKg?.toStringAsFixed(2) ?? '0.00'}/kg'
                            : 'R\$ ${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (product.isSoldByWeight ? product.isAvailable : (product.isAvailable && product.stock > 0))
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (product.isSoldByWeight ? product.isAvailable : (product.isAvailable && product.stock > 0))
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: (product.isSoldByWeight ? product.isAvailable : (product.isAvailable && product.stock > 0))
                                ? Colors.green[700]
                                : Colors.red[700],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.isSoldByWeight
                                ? (product.isAvailable ? 'Disponível' : 'Indisponível')
                                : (product.isAvailable && product.stock > 0
                                    ? '${product.stock} un.'
                                    : 'Indisponível'),
                            style: TextStyle(
                              color: (product.isSoldByWeight ? product.isAvailable : (product.isAvailable && product.stock > 0))
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Compact description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descrição',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}