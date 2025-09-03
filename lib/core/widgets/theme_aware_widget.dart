import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Widget base que facilita o uso de cores reativas ao tema
class ThemeAwareWidget extends StatelessWidget {
  final Widget Function(BuildContext context, AppColors colors) builder;

  const ThemeAwareWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, AppColors());
  }
}

/// Extensão para facilitar o acesso às cores reativas
extension ThemeAwareContext on BuildContext {
  /// Cores que reagem automaticamente ao tema
  AppColors get colors => AppColors();
  
  /// Verifica se está no tema escuro
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
  
  /// Verifica se está no tema claro
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;
}

/// Widget que aplica cores reativas automaticamente
class ThemedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;

  const ThemedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface(context),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: borderColor != null || borderWidth != null
            ? Border.all(
                color: borderColor ?? AppColors.border(context),
                width: borderWidth ?? 1,
              )
            : null,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Widget de texto que reage ao tema
class ThemedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  const ThemedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    
    return Text(
      text,
      style: style?.copyWith(
        color: color ?? AppColors.onSurface(context),
      ) ?? TextStyle(
        color: color ?? AppColors.onSurface(context),
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Widget de botão que reage ao tema
class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;

  const ThemedButton(
    this.text, {
    super.key,
    this.onPressed,
    this.type = ButtonType.elevated,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    
    switch (type) {
      case ButtonType.elevated:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.buttonPrimary(context),
            foregroundColor: textColor ?? AppColors.buttonOnPrimary(context),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
            elevation: elevation ?? 2,
          ),
          child: Text(text),
        );
      
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.buttonPrimary(context),
            side: BorderSide(
              color: backgroundColor ?? AppColors.buttonPrimary(context),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
          ),
          child: Text(text),
        );
      
      case ButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColors.buttonPrimary(context),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(text),
        );
    }
  }
}

/// Tipos de botão
enum ButtonType {
  elevated,
  outlined,
  text,
}

/// Widget de card que reage ao tema
class ThemedCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;

  const ThemedCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    
    return Card(
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: borderColor != null || borderWidth != null
            ? BorderSide(
                color: borderColor ?? AppColors.cardBorder(context),
                width: borderWidth ?? 1,
              )
            : BorderSide.none,
      ),
      color: backgroundColor ?? AppColors.cardBackground(context),
      child: padding != null
          ? Padding(
              padding: padding!,
              child: child,
            )
          : child,
    );
  }
}

/// Widget de ícone que reage ao tema
class ThemedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final IconType type;

  const ThemedIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.type = IconType.primary,
  });

  @override
  Widget build(BuildContext context) {
    
    Color iconColor;
    switch (type) {
      case IconType.primary:
        iconColor = color ?? AppColors.iconPrimary(context);
        break;
      case IconType.secondary:
        iconColor = color ?? AppColors.iconSecondary(context);
        break;
    }
    
    return Icon(
      icon,
      size: size,
      color: iconColor,
    );
  }
}

/// Tipos de ícone
enum IconType {
  primary,
  secondary,
}
