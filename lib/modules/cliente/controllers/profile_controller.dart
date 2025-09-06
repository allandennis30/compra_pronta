import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/cep_service.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingCep = false.obs;
  final RxBool isCityLocked = false.obs;
  final RxBool isStateLocked = false.obs;

  // Controllers para os campos editáveis
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController streetController;
  late TextEditingController numberController;
  late TextEditingController complementController;
  late TextEditingController neighborhoodController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipCodeController;

  // Controllers para alterar senha
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    _createControllers();
    user.value = _authController.currentUser;
    _initializeControllers();
    
    // Escutar mudanças no currentUser do AuthController
    ever(_authController.currentUserRx, (UserModel? updatedUser) {
      if (updatedUser != null) {
        user.value = updatedUser;
        _initializeControllers();
      }
    });
  }

  void _createControllers() {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    streetController = TextEditingController();
    numberController = TextEditingController();
    complementController = TextEditingController();
    neighborhoodController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    zipCodeController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    try {
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
    } catch (e) {
      // Ignorar erros se já foram descartados
    }
  }

  void _initializeControllers() {
    final currentUser = user.value;
    if (currentUser != null) {
      try {
        nameController.text = currentUser.name;
        phoneController.text = currentUser.phone;
        streetController.text = currentUser.address.street;
        numberController.text = currentUser.address.number.toString();
        complementController.text = currentUser.address.complement ?? '';
        neighborhoodController.text = currentUser.address.neighborhood;
        cityController.text = currentUser.address.city;
        stateController.text = currentUser.address.state;
        zipCodeController.text = currentUser.address.zipCode;
        
        // Resetar estados de bloqueio ao inicializar
        isCityLocked.value = false;
        isStateLocked.value = false;
      } catch (e) {
        // Se algum controller foi descartado, recriar todos
        _createControllers();
        _initializeControllers();
      }
    }
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Cancelar edição - restaurar valores originais
      _initializeControllers();
      // Desbloquear campos após cancelar edição
      isCityLocked.value = false;
      isStateLocked.value = false;
    }
    isEditing.toggle();
  }

  Future<void> saveProfile() async {
    if (user.value == null) return;

    try {
      isLoading.value = true;

      final updatedAddress = AddressModel(
        street: streetController.text.trim(),
        number: int.parse(numberController.text.trim()),
        complement: complementController.text.trim().isEmpty
            ? null
            : complementController.text.trim(),
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
      // O listener do ever() já atualizará user.value automaticamente
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
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
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

  /// Busca dados do endereço pelo CEP
  Future<void> searchCep() async {
    final cep = zipCodeController.text;
    if (cep.length < 8) return;

    isLoadingCep.value = true;

    try {
      final cepData = await CepService.searchCep(cep);

      if (cepData != null) {
        streetController.text = cepData['logradouro'] ?? '';
        neighborhoodController.text = cepData['bairro'] ?? '';
        cityController.text = cepData['localidade'] ?? '';
        stateController.text = cepData['uf'] ?? '';

        // Bloqueia os campos cidade e UF quando preenchidos automaticamente
        isCityLocked.value = cepData['localidade']?.isNotEmpty == true;
        isStateLocked.value = cepData['uf']?.isNotEmpty == true;

        Get.snackbar(
          'Sucesso',
          'Endereço encontrado e preenchido automaticamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Desbloqueia os campos se o CEP não for encontrado
        isCityLocked.value = false;
        isStateLocked.value = false;

        Get.snackbar(
          'CEP não encontrado',
          'Verifique o CEP informado',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Desbloqueia os campos em caso de erro
      isCityLocked.value = false;
      isStateLocked.value = false;

      Get.snackbar(
        'Erro',
        'Erro ao buscar CEP. Tente novamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCep.value = false;
    }
  }

  /// Desbloqueia os campos cidade e UF para edição manual
  void unlockCityAndState() {
    isCityLocked.value = false;
    isStateLocked.value = false;
  }

  void logout() async {
    await _authController.logout();
  }
}
