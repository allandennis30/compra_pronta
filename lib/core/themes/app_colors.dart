import 'package:flutter/material.dart';

/// Sistema de cores unificado que reage automaticamente ao tema do celular
class AppColors {
  // Cores base (sempre as mesmas)
  static const Color _primaryBase = Color(0xFF2E7D32);
  static const Color _secondaryBase = Color(0xFF4CAF50);
  static const Color _accentBase = Color(0xFF8BC34A);
  static const Color _errorBase = Color(0xFFD32F2F);
  static const Color _warningBase = Color(0xFFFF9800);
  static const Color _successBase = Color(0xFF4CAF50);

  // Cores que mudam com o tema
  static Color primary(BuildContext context) => _primaryBase;
  static Color secondary(BuildContext context) => _secondaryBase;
  static Color accent(BuildContext context) => _accentBase;
  static Color error(BuildContext context) => _errorBase;
  static Color warning(BuildContext context) => _warningBase;
  static Color success(BuildContext context) => _successBase;

  // Cores de fundo que reagem ao tema
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5);
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color surfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF8F9FA);
  }

  // Cores de texto que reagem ao tema
  static Color onBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color onSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color onSurfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[700]!;
  }

  // Cores de borda que reagem ao tema
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[300]!;
  }

  static Color borderFocused(BuildContext context) {
    return primary(context);
  }

  static Color borderError(BuildContext context) {
    return error(context);
  }

  // Cores de card que reagem ao tema
  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color cardBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[200]!;
  }

  // Cores de botão que reagem ao tema
  static Color buttonPrimary(BuildContext context) => primary(context);
  static Color buttonSecondary(BuildContext context) => secondary(context);
  static Color buttonOnPrimary(BuildContext context) => Colors.white;
  static Color buttonOnSecondary(BuildContext context) => Colors.white;

  static Color buttonOutlined(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[700]!;
  }

  // Cores de AppBar que reagem ao tema
  static Color appBarBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : primary(context);
  }

  static Color appBarForeground(BuildContext context) => Colors.white;

  // Cores de status que reagem ao tema
  static Color statusPending(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange[300]!
        : Colors.orange[600]!;
  }

  static Color statusConfirmed(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue[300]!
        : Colors.blue[600]!;
  }

  static Color statusPreparing(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.purple[300]!
        : Colors.purple[600]!;
  }

  static Color statusDelivering(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.cyan[300]!
        : Colors.cyan[600]!;
  }

  static Color statusDelivered(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green[300]!
        : Colors.green[600]!;
  }

  static Color statusCancelled(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red[300]!
        : Colors.red[600]!;
  }

  // Cores de destaque que reagem ao tema
  static Color highlight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue[200]!
        : Colors.blue[100]!;
  }

  static Color shadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);
  }

  // Cores de divisão que reagem ao tema
  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!;
  }

  // Cores de ícone que reagem ao tema
  static Color iconPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color iconSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
  }

  // Cores de overlay que reagem ao tema
  static Color overlay(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withOpacity(0.7)
        : Colors.black.withOpacity(0.5);
  }

  // Cores de snackbar que reagem ao tema
  static Color snackbarSuccess(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green[800]!
        : Colors.green[600]!;
  }

  static Color snackbarError(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red[800]!
        : Colors.red[600]!;
  }

  static Color snackbarWarning(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange[800]!
        : Colors.orange[600]!;
  }

  static Color snackbarInfo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue[800]!
        : Colors.blue[600]!;
  }

  // Cores de loading que reagem ao tema
  static Color loadingIndicator(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : primary(context);
  }

  // Cores de progresso que reagem ao tema
  static Color progressBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!;
  }

  static Color progressValue(BuildContext context) => primary(context);

  // Cores de switch que reagem ao tema
  static Color switchActive(BuildContext context) => primary(context);
  static Color switchInactive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[400]!;
  }

  // Cores de chip que reagem ao tema
  static Color chipBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;
  }

  static Color chipSelected(BuildContext context) => primary(context);
  static Color chipText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  // Cores de tab que reagem ao tema
  static Color tabSelected(BuildContext context) => primary(context);
  static Color tabUnselected(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
  }

  // Cores de drawer que reagem ao tema
  static Color drawerBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color drawerHeader(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : primary(context);
  }

  // Cores de list tile que reagem ao tema
  static Color listTileBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.transparent
        : Colors.transparent;
  }

  static Color listTileSelected(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[100]!;
  }

  // Cores de floating action button que reagem ao tema
  static Color fabBackground(BuildContext context) => primary(context);
  static Color fabForeground(BuildContext context) => Colors.white;

  // Cores de bottom navigation que reagem ao tema
  static Color bottomNavBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color bottomNavSelected(BuildContext context) => primary(context);
  static Color bottomNavUnselected(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
  }
}
