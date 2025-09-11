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
  final RxString _userMode = 'cliente'.obs; // Modo padrão: cliente

  UserModel? get currentUser => _currentUser.value;
  Rx<UserModel?> get currentUserRx => _currentUser;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String get userMode => _userMode.value;
  RxString get userModeRx => _userMode;

  @override
  void onInit() {
    super.onInit();
    _isLoading.value = true;
    // Usar addPostFrameCallback para evitar problemas de build scope
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoAuthenticate();
    });
  }

  /// Método de teste para verificar o estado do storage
  Future<void> debugStorage() async {
    try {
      await _authRepository.getToken();
      await _authRepository.getCurrentUser();
      await _authRepository.hasSavedCredentials();
      await _authRepository.getSavedCredentials();
    } catch (e) {
      AppLogger.error('❌ [DEBUG] Erro ao verificar storage', e);
    }
  }

  /// Autenticação automática na inicialização do app
  void _autoAuthenticate() async {
    try {
      // Debug do storage
      await debugStorage();

      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        // Verificar se o token ainda é válido
        final isValid = await _verifyTokenValidity();
        if (isValid) {
          _loadUserFromStorage();
        } else {
          _refreshToken();
        }
      } else {
        // Tentar login automático com credenciais salvas
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
      final verifyTokenEndpoint = await AppConstants.verifyTokenEndpoint;
      final response = await http.post(
        Uri.parse(verifyTokenEndpoint),
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

      final refreshTokenEndpoint = await AppConstants.refreshTokenEndpoint;
      final response = await http.post(
        Uri.parse(refreshTokenEndpoint),
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
        AppLogger.info('📱 Carregando usuário do storage: ${user.name}');
        _currentUser.value = user;
        _isLoggedIn.value = true;
        
        // Carregar modo do usuário salvo
        await loadUserMode();
        
        // Forçar notificação dos listeners após carregar usuário do storage
        AppLogger.info('🔔 Notificando controllers sobre usuário carregado do storage');
        _currentUser.refresh();
        AppLogger.info('✅ Notificação enviada para listeners');
        
        // Buscar dados atualizados do servidor
        await _fetchUpdatedUserData();
      } else {
        await _authRepository.logout();
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao carregar usuário do storage', e);
      await _authRepository.logout();
    }
  }

  /// Busca dados atualizados do usuário no servidor
  Future<void> _fetchUpdatedUserData() async {
    try {
      AppLogger.info('📡 Buscando dados atualizados do servidor...');
      
      final token = await _authRepository.getToken();
      if (token == null) {
        AppLogger.warning('⚠️ Token não encontrado para buscar dados do servidor');
        return;
      }

      final profileEndpoint = await AppConstants.profileEndpoint;
      final response = await http.get(
        Uri.parse(profileEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['user'] != null) {
          final updatedUser = UserModel.fromJson(responseData['user']);
          
          // Atualizar dados no storage e na memória
          await _authRepository.saveUser(updatedUser);
          _currentUser.value = updatedUser;
          AppLogger.info('🔔 Notificando controllers sobre dados atualizados do servidor');
          _currentUser.refresh();
          
          AppLogger.success('✅ Dados do usuário atualizados do servidor');
        }
      } else {
        AppLogger.warning('⚠️ Falha ao buscar dados do servidor: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao buscar dados atualizados do servidor', e);
      // Não fazer logout em caso de erro de rede, manter dados locais
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
          
          // Forçar notificação dos listeners após login bem-sucedido
          _currentUser.refresh();
          AppLogger.info('🔔 Notificando controllers sobre login bem-sucedido');
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
    bool isSeller = false,
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
        isSeller: isSeller,
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

  Future<void> updateUser(UserModel user) async {
    try {
      await _authRepository.updateUser(user);
      _currentUser.value = user;
    } catch (e) {
      AppLogger.error('Erro ao atualizar usuário', e);
      rethrow;
    }
  }

  /// Recarrega dados do usuário atual do repositório
  Future<void> reloadCurrentUser() async {
    try {
      // Primeiro carrega do storage local
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser.value = user;
        AppLogger.info('✅ Dados do usuário recarregados do storage');
        
        // Depois busca dados atualizados do servidor
        await _fetchUpdatedUserData();
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao recarregar dados do usuário', e);
      rethrow;
    }
  }

  bool get isVendor => currentUser?.isSeller ?? false;
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
    await _refreshToken();
  }

  /// Métodos para gerenciar o modo do usuário (cliente/entregador)
  Future<void> saveUserMode(String mode) async {
    try {
      await _authRepository.saveUserMode(mode);
      _userMode.value = mode;
      AppLogger.info('💾 Modo do usuário alterado para: $mode');
    } catch (e) {
      AppLogger.error('❌ Erro ao salvar modo do usuário', e);
    }
  }

  Future<void> loadUserMode() async {
    try {
      final savedMode = await _authRepository.getUserMode();
      if (savedMode != null) {
        _userMode.value = savedMode;
        AppLogger.info('📖 Modo do usuário carregado: $savedMode');
      } else {
        // Se não há modo salvo, usar 'cliente' como padrão
        _userMode.value = 'cliente';
        AppLogger.info('📖 Usando modo padrão: cliente');
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao carregar modo do usuário', e);
      _userMode.value = 'cliente'; // Fallback para cliente
    }
  }

  Future<void> clearUserMode() async {
    try {
      await _authRepository.clearUserMode();
      _userMode.value = 'cliente';
      AppLogger.info('🗑️ Modo do usuário limpo, voltando para cliente');
    } catch (e) {
      AppLogger.error('❌ Erro ao limpar modo do usuário', e);
    }
  }

  /// Verifica se o usuário está no modo entregador
  bool get isDeliveryMode => _userMode.value == 'entregador';

  /// Verifica se o usuário está no modo cliente
  bool get isClientMode => _userMode.value == 'cliente';
}
