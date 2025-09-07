import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_controller.dart';

class UpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final bool isForced;

  const UpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    this.isForced = false,
  });

  @override
  Widget build(BuildContext context) {
    final updateController = Get.find<UpdateController>();
    
    return PopScope(
      canPop: !isForced,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: Get.theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Atualização Disponível',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uma nova versão do Mercax está disponível!',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Versão atual:',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        currentVersion,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nova versão:',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        latestVersion,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isForced
                  ? 'Esta atualização é obrigatória para continuar usando o app.'
                  : 'Atualize agora para aproveitar as melhorias e correções.',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: isForced
                    ? Get.theme.colorScheme.error
                    : Get.theme.colorScheme.onSurface,
                fontWeight: isForced ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (!isForced)
            TextButton(
              onPressed: () => updateController.dismissUpdateDialog(),
              child: Text(
                'Agora não',
                style: TextStyle(
                  color: Get.theme.colorScheme.outline,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => updateController.openPlayStore(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Get.theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Atualizar',
                  style: Get.textTheme.labelLarge?.copyWith(
                    color: Get.theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Método estático para exibir o dialog
  static void show({
    required String currentVersion,
    required String latestVersion,
    bool isForced = false,
  }) {
    Get.dialog(
      UpdateDialog(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        isForced: isForced,
      ),
      barrierDismissible: !isForced,
    );
  }
}