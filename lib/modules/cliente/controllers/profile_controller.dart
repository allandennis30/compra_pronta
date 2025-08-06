import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;
  
  // Controllers para os campos editáveis
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();
  
  // Controllers para alterar senha
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    user.value = _authController.currentUser;
    _initializeControllers();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    numberController.dispose();
    complementController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  void _initializeControllers() {
    final currentUser = user.value;
    if (currentUser != null) {
      nameController.text = currentUser.name;
      phoneController.text = currentUser.phone;
      streetController.text = currentUser.address.street;
      numberController.text = currentUser.address.number;
      complementController.text = currentUser.address.complement ?? '';
      neighborhoodController.text = currentUser.address.neighborhood;
      cityController.text = currentUser.address.city;
      stateController.text = currentUser.address.state;
      zipCodeController.text = currentUser.address.zipCode;
    }
  }
  
  void toggleEdit() {
    if (isEditing.value) {
      // Cancelar edição - restaurar valores originais
      _initializeControllers();
    }
    isEditing.toggle();
  }
  
  Future<void> saveProfile() async {
    if (user.value == null) return;
    
    try {
      isLoading.value = true;
      
      final updatedAddress = AddressModel(
        street: streetController.text.trim(),
        number: numberController.text.trim(),
        complement: complementController.text.trim().isEmpty ? null : complementController.text.trim(),
        neighborhood: neighborhoodController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        zipCode: zipCodeController.text.trim(),
      );
      
      final updatedUser = UserModel(
        id: user.value!.id,
        name: nameController.text.trim(),
        email: user.value!.email, // Email não pode ser alterado
        phone: phoneController.text.trim(),
        address: updatedAddress,
        latitude: user.value!.latitude,
        longitude: user.value!.longitude,
        istore: user.value!.istore,
      );
      
      _authController.updateUser(updatedUser);
      user.value = updatedUser;
      isEditing.value = false;
      
      Get.snackbar(
        'Sucesso',
        'Perfil atualizado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar perfil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void showChangePasswordDialog() {
    // Limpar campos
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Senha atual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nova senha',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar nova senha',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : changePassword,
            child: isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Alterar'),
          )),
        ],
      ),
    );
  }
  
  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    
    // Validações
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Erro',
        'Todos os campos são obrigatórios',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Erro',
        'Nova senha e confirmação não conferem',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (newPassword.length < 6) {
      Get.snackbar(
        'Erro',
        'A nova senha deve ter pelo menos 6 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Simular validação da senha atual e alteração
      await Future.delayed(const Duration(seconds: 1));
      
      // Em uma implementação real, aqui seria feita a validação da senha atual
      // e a alteração no backend
      
      Get.back(); // Fechar dialog
      Get.snackbar(
        'Sucesso',
        'Senha alterada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao alterar senha: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _authController.logout();
  }
}
