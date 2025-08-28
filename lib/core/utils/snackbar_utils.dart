import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    final theme = Theme.of(context);
    _showSnackBar(
      context,
      message,
      backgroundColor: theme.colorScheme.primary,
      icon: Icons.check_circle,
    );
  }

  static void showError(BuildContext context, String message) {
    final theme = Theme.of(context);
    _showSnackBar(
      context,
      message,
      backgroundColor: theme.colorScheme.error,
      icon: Icons.error,
    );
  }

  static void showInfo(BuildContext context, String message) {
    final theme = Theme.of(context);
    _showSnackBar(
      context,
      message,
      backgroundColor: theme.colorScheme.secondary,
      icon: Icons.info,
    );
  }

  static void showWarning(BuildContext context, String message) {
    final theme = Theme.of(context);
    _showSnackBar(
      context,
      message,
      backgroundColor: theme.colorScheme.tertiary ?? Colors.amber,
      icon: Icons.warning,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Verificar se o contexto ainda é válido antes de usar
    if (!context.mounted) return;
    
    try {
      // Remove qualquer SnackBar existente antes de mostrar um novo
      ScaffoldMessenger.of(context).clearSnackBars();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: 'Fechar',
            textColor: Colors.white,
            onPressed: () {
              // Verificar se o contexto ainda é válido antes de usar
              if (context.mounted) {
                try {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                } catch (e) {
                  // Ignorar erro se o contexto não for válido
                }
              }
            },
          ),
        ),
      );
    } catch (e) {
      // Se houver erro ao mostrar SnackBar, apenas logar (não quebrar o app)
      debugPrint('Erro ao mostrar SnackBar: $e');
    }
  }
}