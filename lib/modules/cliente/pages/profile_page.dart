import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/themes/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: controller.isEditing.value
                      ? controller.saveProfile
                      : controller.toggleEdit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(48, 48),
                  ),
                  child: Icon(
                      controller.isEditing.value ? Icons.save : Icons.edit),
                ),
              )),
        ],
      ),
      body: Obx(() {
        final user = controller.user.value;
        if (user == null) {
          return const Center(child: Text('Usuário não encontrado.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de dados pessoais
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados Pessoais',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        label: 'Nome',
                        controller: controller.nameController,
                        readOnly: !controller.isEditing.value,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        label: 'E-mail',
                        initialValue: user.email,
                        readOnly: true, // Email nunca pode ser editado
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        label: 'Telefone',
                        controller: controller.phoneController,
                        readOnly: !controller.isEditing.value,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seção de endereço
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Endereço',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              context: context,
                              label: 'Rua',
                              controller: controller.streetController,
                              readOnly: !controller.isEditing.value,
                              icon: Icons.location_on,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildTextField(
                              context: context,
                              label: 'Número',
                              controller: controller.numberController,
                              readOnly: !controller.isEditing.value,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        label: 'Complemento',
                        controller: controller.complementController,
                        readOnly: !controller.isEditing.value,
                        icon: Icons.home,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        label: 'Bairro',
                        controller: controller.neighborhoodController,
                        readOnly: !controller.isEditing.value,
                        icon: Icons.location_city,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              context: context,
                              label: 'Cidade',
                              controller: controller.cityController,
                              readOnly: !controller.isEditing.value,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildTextField(
                              context: context,
                              label: 'Estado',
                              controller: controller.stateController,
                              readOnly: !controller.isEditing.value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context: context,
                        label: 'CEP',
                        controller: controller.zipCodeController,
                        readOnly: !controller.isEditing.value,
                        icon: Icons.mail,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botões de ação
              if (controller.isEditing.value) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.toggleEdit,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.saveProfile,
                            icon: controller.isLoading.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: const Text('Salvar'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Botão alterar senha
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.showChangePasswordDialog,
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Alterar Senha'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botão sair
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    TextEditingController? controller,
    String? initialValue,
    bool readOnly = false,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        filled: readOnly,
        fillColor: readOnly ? AppColors.surfaceVariant(context) : null,
      ),
    );
  }
}
