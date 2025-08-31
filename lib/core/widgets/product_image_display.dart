import 'package:flutter/material.dart';

/// Widget reutilizável para exibir imagens de produtos em todo o app
/// Trata automaticamente URLs vazias, erros de carregamento e estados de loading
class ProductImageDisplay extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showLoadingIndicator;

  const ProductImageDisplay({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.showLoadingIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    // Se não há URL ou está vazia, mostrar placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    // Verificar se é uma URL de placeholder que pode não estar acessível
    if (_isPlaceholderUrl(imageUrl!)) {
      return _buildPlaceholder(context);
    }

    // Se há URL, tentar carregar a imagem
    return _buildImageWithUrl(context);
  }

  /// Verifica se a URL é um placeholder que pode não estar acessível
  bool _isPlaceholderUrl(String url) {
    return url.contains('via.placeholder.com') ||
        url.contains('placeholder.com') ||
        url.contains('picsum.photos') && url.contains('random=');
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey[400],
        size: _getIconSize(),
      ),
    );
  }

  Widget _buildImageWithUrl(BuildContext context) {
    Widget imageWidget = Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: showLoadingIndicator
          ? (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: borderRadius,
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
            }
          : null,
      errorBuilder: (context, error, stackTrace) {
        if (errorWidget != null) {
          return errorWidget!;
        }

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: borderRadius,
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[600],
            size: _getIconSize(),
          ),
        );
      },
    );

    // Aplicar borderRadius se especificado
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  double _getIconSize() {
    if (width != null && height != null) {
      return (width! + height!) / 4; // Tamanho proporcional
    }
    return 32; // Tamanho padrão
  }
}

/// Widget para exibir imagem de produto em formato circular (avatar)
class ProductAvatarDisplay extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProductAvatarDisplay({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ProductImageDisplay(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      placeholder: placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: errorWidget ?? _buildDefaultErrorWidget(),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shopping_bag,
        color: Colors.grey[600],
        size: size * 0.4,
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shopping_bag,
        color: Colors.grey[600],
        size: size * 0.4,
      ),
    );
  }
}

/// Widget para exibir imagem de produto em formato de card
class ProductCardImageDisplay extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProductCardImageDisplay({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ProductImageDisplay(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      placeholder: _buildCardPlaceholder(),
      errorWidget: _buildCardErrorWidget(),
    );
  }

  Widget _buildCardPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey[400],
        size: 32,
      ),
    );
  }

  Widget _buildCardErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[400],
        size: 32,
      ),
    );
  }
}
