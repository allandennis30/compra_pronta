import 'package:flutter/material.dart';
import '../../cliente/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildProductImage(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductInfo(context),
                ),
                const SizedBox(width: 12),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.imageUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey[400],
                size: 32,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.name ?? 'Produto sem nome',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusIndicator(),
          ],
        ),
        const SizedBox(height: 6),
        _buildPriceInfo(),
        const SizedBox(height: 6),
        _buildCategoryChip(),
        const SizedBox(height: 8),
        _buildStockInfo(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (product.isAvailable ?? false)
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (product.isAvailable ?? false)
              ? Colors.green.shade200
              : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: (product.isAvailable ?? false)
                  ? Colors.green.shade500
                  : Colors.red.shade500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            (product.isAvailable ?? false) ? 'Ativo' : 'Inativo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: (product.isAvailable ?? false)
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Row(
      children: [
        Icon(
          (product.isSoldByWeight ?? false) ? Icons.scale : Icons.attach_money,
          size: 16,
          color: Colors.green.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          (product.isSoldByWeight ?? false)
              ? 'R\$ ${(product.pricePerKg ?? 0.0).toStringAsFixed(2)}/kg'
              : 'R\$ ${(product.price ?? 0.0).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 0.5,
        ),
      ),
      child: Text(
        product.category ?? 'Sem categoria',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    if (product.isSoldByWeight ?? false) {
      return Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            'Vendido por peso',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    final stockColor = (product.stock ?? 0) > 10
        ? Colors.green.shade600
        : (product.stock ?? 0) > 0
            ? Colors.orange.shade600
            : Colors.red.shade600;

    final stockIcon = (product.stock ?? 0) > 10
        ? Icons.check_circle_outline
        : (product.stock ?? 0) > 0
            ? Icons.warning_amber_outlined
            : Icons.error_outline;

    return Row(
      children: [
        Icon(
          stockIcon,
          size: 14,
          color: stockColor,
        ),
        const SizedBox(width: 4),
        Text(
          'Estoque: ${product.stock ?? 0}',
          style: TextStyle(
            fontSize: 12,
            color: stockColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          onTap: onEdit,
          color: Colors.blue.shade600,
          tooltip: 'Editar produto',
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: (product.isAvailable ?? false)
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onTap: onToggleStatus,
          color: (product.isAvailable ?? false)
              ? Colors.orange.shade600
              : Colors.green.shade600,
          tooltip: (product.isAvailable ?? false)
              ? 'Desativar produto'
              : 'Ativar produto',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
    required String tooltip,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
