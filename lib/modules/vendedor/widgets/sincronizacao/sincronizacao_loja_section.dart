import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/vendor_settings_controller.dart';

class SincronizacaoLojaSection extends StatelessWidget {
  final VendedorSettingsController controller;

  const SincronizacaoLojaSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar com Servidor'),
              onPressed: controller.sincronizarComServidor,
            ),
            SwitchListTile(
              title: const Text('Modo Loja Offline'),
              value: controller.lojaOffline.value,
              onChanged: (v) => controller.lojaOffline.value = v,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              label: const Text('Backup Manual'),
              onPressed: controller.backupManual,
            ),
            const SizedBox(height: 16),
          ],
        ));
  }
}
