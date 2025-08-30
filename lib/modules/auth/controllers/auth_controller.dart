import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../constants/app_constants.dart';
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
    _autoAuthenticate();
  }

  /// Método de teste para verificar o estado do storage
  Future<void> debugStorage() async {
    try {
      AppLogger.info('🔍 [DEBUG] Verificando estado do storage...');

      final token = await _authRepository.getToken();
      final user = await _authRepository.getCurrentUser();
      final hasCredentials = await _authRepository.hasSavedCredentials();
      final credentials = await _authRepository.getSavedCredentials();

      AppLogger.info(
          '🔍 [DEBUG] Token: ${token != null ? 'presente' : 'null'}');
      AppLogger.info(
          '🔍 [DEBUG] Usuário: ${user != null ? user.name : 'null'}');
      AppLogger.info('🔍 [DEBUG] Tem credenciais: $hasCredentials');
      AppLogger.info(
          '🔍 [DEBUG] Credenciais: ${credentials != null ? 'presentes' : 'null'}');

      if (credentials != null) {
        AppLogger.info('🔍 [DEBUG] Email salvo: ${credentials['email']}');
        AppLogger.info(
            '🔍 [DEBUG] Senha salva: ${credentials['password']?.isNotEmpty == true ? 'presente' : 'vazia'}');
      }
    } catch (e) {
      AppLogger.error('❌ [DEBUG] Erro ao verificar storage', e);
    }
  }

  /// Autenticação automática na inicialização do app
  void _autoAuthenticate() async {
    try {
      AppLogger.info('🔄 Iniciando autenticação automática...');

      // Debug do storage
      await debugStorage();

      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        AppLogger.info('🔑 Token encontrado, verificando validade...');

        // Verificar se o token ainda é válido
        final isValid = await _verifyTokenValidity();
        if (isValid) {
          AppLogger.success('✅ Token válido, carregando usuário...');
          _loadUserFromStorage();
        } else {
          AppLogger.warning('⚠️ Token expirado, tentando renovar...');
          _refreshToken();
        }
      } else {
        // Tentar login automático com credenciais salvas
        AppLogger.info(
            'ℹ️ Nenhum token encontrado, tentando login automático...');
        await _tryAutoLogin();
      }
    } catch (e) {
      AppLogger.error('❌ Erro na autenticação automática', e);
      // Em caso de erro, limpar dados corrompidos
      await _authRepository.logout();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verifica se o token atual é válido
  Future<bool> _verifyTokenValidity() async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) return false;

      // Fazer requisição para verificar token
      final response = await http.post(
        Uri.parse(AppConstants.verifyTokenEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('❌ Erro ao verificar token', e);
      return false;
    }
  }

  /// Tenta renovar o token atual
  Future<void> _refreshToken() async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        await _authRepository.logout();
        return;
      }

      AppLogger.info('🔄 Tentando renovar token...');

      final response = await http.post(
        Uri.parse(AppConstants.refreshTokenEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newToken = responseData['token'];

        if (newToken != null) {
          await _authRepository.saveToken(newToken);
          AppLogger.success('✅ Token renovado com sucesso');

          // Carregar usuário com o novo token
          _loadUserFromStorage();
          return;
        }
      }

      // Se não conseguiu renovar, fazer logout
      AppLogger.warning('⚠️ Não foi possível renovar o token');
      await _authRepository.logout();
    } catch (e) {
      AppLogger.error('❌ Erro ao renovar token', e);
      await _authRepository.logout();
    }
  }

  void _loadUserFromStorage() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser.value = user;
        _isLoggedIn.value = true;
        AppLogger.success('✅ Usuário carregado: ${user.name}');
      } else {
        AppLogger.warning('⚠️ Usuário não encontrado no storage');
        await _authRepository.logout();
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao carregar usuário do storage', e);
      await _authRepository.logout();
    }
  }

  /// Tenta fazer login automático com credenciais salvas
  Future<void> _tryAutoLogin() async {
    try {
      final hasCredentials = await _authRepository.hasSavedCredentials();
      if (!hasCredentials) {
        AppLogger.info('ℹ️ Nenhuma credencial salva encontrada');
        return;
      }

      AppLogger.info('🔐 Tentando login automático com credenciais salvas...');

      final credentials = await _authRepository.getSavedCredentials();
      if (credentials != null) {
        final email = credentials['email']!;
        final password = credentials['password']!;

        // Fazer login com as credenciais salvas
        final success = await login(email, password, Get.context!);
        if (success) {
          AppLogger.success('✅ Login automático realizado com sucesso!');
        } else {
          AppLogger.warning(
              '⚠️ Login automático falhou, credenciais podem estar incorretas');
          // Limpar credenciais incorretas
          await _authRepository.clearSavedCredentials();
        }
      }
    } catch (e) {
      AppLogger.error('❌ Erro no login automático', e);
      // Em caso de erro, limpar credenciais corrompidas
      await _authRepository.clearSavedCredentials();
    }
  }

  Future<bool> login(String email, String password, BuildContext context,
      {bool saveCredentials = true}) async {
    _isLoading.value = true;

    try {
      AppLogger.info('🔐 Iniciando login para: $email');

      final user = await _authRepository.login(email, password);

      if (user != null) {
        _currentUser.value = user;
        _isLoggedIn.value = true;

        // Verificar se o token é válido após o login
        final isTokenValid = await _verifyTokenValidity();
        if (isTokenValid) {
          AppLogger.success(
              '✅ Login realizado com sucesso: ${user.name} - Token válido');

          // Salvar credenciais se o usuário escolheu
          if (saveCredentials) {
            await _authRepository.saveCredentials(email, password);
          }
        } else {
          AppLogger.warning('⚠️ Login realizado mas token inválido');
        }

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
      AppLogger.info('🚪 Iniciando logout...');

      await _authRepository.logout();
      _currentUser.value = null;
      _isLoggedIn.value = false;

      AppLogger.success('✅ Logout realizado com sucesso');

      // Redirecionar para tela de login
      Get.offAllNamed('/login');
    } catch (e) {
      AppLogger.error('❌ Erro ao fazer logout', e);
      // Mesmo com erro, limpar dados locais
      _currentUser.value = null;
      _isLoggedIn.value = false;
      Get.offAllNamed('/login');
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

  /// Verifica e renova o token automaticamente
  Future<bool> verifyAndRefreshToken() async {
    try {
      AppLogger.info('🔄 Verificando e renovando token...');

      final isAuthenticated = await _authRepository.isAuthenticated();
      if (!isAuthenticated) {
        AppLogger.warning('⚠️ Usuário não autenticado');
        return false;
      }

      final isValid = await _verifyTokenValidity();
      if (isValid) {
        AppLogger.success('✅ Token válido');
        return true;
      }

      AppLogger.warning('⚠️ Token inválido, tentando renovar...');
      _refreshToken();
      return false;
    } catch (e) {
      AppLogger.error('❌ Erro ao verificar token', e);
      return false;
    }
  }

  /// Força a renovação do token
  Future<void> forceTokenRefresh() async {
    AppLogger.info('🔄 Forçando renovação do token...');
    _refreshToken();
  }
}
