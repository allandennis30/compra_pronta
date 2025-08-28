import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';
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
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          _currentUser.value = user;
          _isLoggedIn.value = true;
        } else {
          // Token existe mas usuário não, limpar dados
          await _authRepository.logout();
        }
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar usuário do storage', e);
      // Em caso de erro, fazer logout para limpar dados corrompidos
      await _authRepository.logout();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password, BuildContext context) async {
    _isLoading.value = true;

    try {
      final user = await _authRepository.login(email, password);

      if (user != null) {
        _currentUser.value = user;
        _isLoggedIn.value = true;
        return true;
      } else {
        // Verificar se o contexto ainda é válido antes de mostrar SnackBar
        if (context.mounted) {
          SnackBarUtils.showError(context, 'Email ou senha incorretos');
        }
        return false;
      }
    } catch (e) {
      // Verificar se o contexto ainda é válido antes de mostrar SnackBar
      if (context.mounted) {
        SnackBarUtils.showError(context, 'Erro ao fazer login: $e');
      }
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
    required BuildContext context,
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

      // Verificar se o contexto ainda é válido antes de mostrar SnackBar
      if (context.mounted) {
        SnackBarUtils.showSuccess(context, 'Conta criada com sucesso!');
      }

      return true;
    } catch (e) {
      // Verificar se o contexto ainda é válido antes de mostrar SnackBar
      if (context.mounted) {
        SnackBarUtils.showError(context, 'Erro ao criar conta: $e');
      }
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

  /// Obtém o token JWT para requisições autenticadas
  Future<String?> getAuthToken() async {
    return await _authRepository.getToken();
  }

  /// Verifica se o usuário está autenticado
  Future<bool> checkAuthentication() async {
    return await _authRepository.isAuthenticated();
  }
}
