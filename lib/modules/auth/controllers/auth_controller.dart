import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/logger.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;

  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    _isLoading.value = true;
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser.value = user;
        _isLoggedIn.value = true;
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar usuário do storage', e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading.value = true;

    try {
      final user = await _authRepository.login(email, password);

      if (user != null) {
        _currentUser.value = user;
        _isLoggedIn.value = true;
        return true;
      } else {
        Get.snackbar(
          'Erro',
          'Email ou senha incorretos',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao fazer login: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required AddressModel address,
    required double latitude,
    required double longitude,
    bool istore = false,
  }) async {
    _isLoading.value = true;

    try {
      final user = await _authRepository.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        istore: istore,
      );

      _currentUser.value = user;
      _isLoggedIn.value = true;

      Get.snackbar(
        'Sucesso',
        'Conta criada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao criar conta: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _currentUser.value = null;
      _isLoggedIn.value = false;

      Get.offAllNamed('/login');
    } catch (e) {
      AppLogger.error('Erro ao fazer logout', e);
    }
  }

  void updateUser(UserModel user) async {
    try {
      await _authRepository.updateUser(user);
      _currentUser.value = user;
    } catch (e) {
      AppLogger.error('Erro ao atualizar usuário', e);
    }
  }

  bool get isVendor => currentUser?.istore ?? false;
  bool get isClient => !isVendor;
}
