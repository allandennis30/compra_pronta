import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Obx(() {
        final user = controller.user.value;
        if (user == null) {
          return const Center(child: Text('Usuário não encontrado.'));
        }
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nome', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                initialValue: user.name,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              const Text('E-mail',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                initialValue: user.email,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              const Text('Telefone',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                initialValue: user.phone,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              const Text('Endereço',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                initialValue: user.address.fullAddress,
                readOnly: true,
                maxLines: 2,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
