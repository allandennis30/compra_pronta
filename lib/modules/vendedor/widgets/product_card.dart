import 'package:flutter/material.dart';
import '../../cliente/models/product_model.dart';
import '../../../core/widgets/product_image_display.dart';
import '../../../core/themes/app_colors.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
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
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ProductCardImageDisplay(
      imageUrl: product.imageUrl,
      width: 80,
      height: 80,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusIndicator(context),
          ],
        ),
        const SizedBox(height: 6),
        _buildPriceInfo(context),
        const SizedBox(height: 6),
        _buildCategoryChip(context),
        const SizedBox(height: 8),
        _buildStockInfo(context),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final isAvailable = product.isAvailable ?? false;
    final statusColor = isAvailable ? AppColors.success(context) : AppColors.error(context);
    final statusColorLight = isAvailable 
        ? AppColors.success(context).withOpacity(0.1)
        : AppColors.error(context).withOpacity(0.1);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? 'Ativo' : 'Inativo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          (product.isSoldByWeight ?? false) ? Icons.scale : Icons.attach_money,
          size: 16,
          color: AppColors.success(context),
        ),
        const SizedBox(width: 4),
        Text(
          (product.isSoldByWeight ?? false)
              ? 'R\$ ${(product.pricePerKg ?? 0.0).toStringAsFixed(2)}/kg'
              : 'R\$ ${(product.price ?? 0.0).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.success(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary(context).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        product.category ?? 'Sem categoria',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary(context),
        ),
      ),
    );
  }

  Widget _buildStockInfo(BuildContext context) {
    if (product.isSoldByWeight ?? false) {
      return Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 14,
            color: AppColors.iconSecondary(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Vendido por peso',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant(context),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    final stock = product.stock ?? 0;
    final stockColor = stock > 10
        ? AppColors.success(context)
        : stock > 0
            ? AppColors.warning(context)
            : AppColors.error(context);

    final stockIcon = stock > 10
        ? Icons.check_circle_outline
        : stock > 0
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
          'Estoque: $stock',
          style: TextStyle(
            fontSize: 12,
            color: stockColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.edit_outlined,
          onTap: onEdit,
          color: AppColors.primary(context),
          tooltip: 'Editar produto',
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context: context,
          icon: (product.isAvailable ?? false)
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onTap: onToggleStatus,
          color: (product.isAvailable ?? false)
              ? AppColors.warning(context)
              : AppColors.success(context),
          tooltip: (product.isAvailable ?? false)
              ? 'Desativar produto'
              : 'Ativar produto',
        ),
        if (onDelete != null) ...[
          const SizedBox(height: 8),
          _buildActionButton(
            context: context,
            icon: Icons.delete_outline,
            onTap: onDelete,
            color: AppColors.error(context),
            tooltip: 'Excluir produto',
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
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
          child: Padding(
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
