import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required AddressModel address,
    required double latitude,
    required double longitude,
    bool istore = false,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> logout();
  Future<void> updateUser(UserModel user);
  Future<String?> getToken();
  Future<bool> isAuthenticated();
  Future<void> saveToken(String token);
  Future<DateTime?> getLastLoginTime();
  Future<bool> shouldRefreshToken();

  // Métodos para credenciais salvas
  Future<void> saveCredentials(String email, String password);
  Future<Map<String, String>?> getSavedCredentials();
  Future<void> clearSavedCredentials();
  Future<bool> hasSavedCredentials();
}

class AuthRepositoryImpl implements AuthRepository {
  final GetStorage _storage = GetStorage();

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      // Log da requisição
      AppLogger.info(
          '🔐 Iniciando login - Email: $email - Endpoint: ${AppConstants.loginEndpoint}');

      final response = await http
          .post(
        Uri.parse(AppConstants.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'senha': password,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: Servidor demorou para responder');
        },
      );

      // Log da resposta
      AppLogger.info(
          '📡 Resposta do login recebida - Status: ${response.statusCode} - Tamanho: ${response.body.length}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Log do sucesso
        AppLogger.success(
            '✅ Login realizado com sucesso - UserID: ${responseData['user']?['id']} - Tipo: ${responseData['user']?['tipo']}');

        // Salvar token JWT
        final token = responseData['token'];
        if (token != null) {
          await _storage.write(AppConstants.tokenKey, token);
          AppLogger.info('💾 Token JWT salvo no storage');
        }

        // Salvar credenciais para login automático futuro
        await saveCredentials(email, password);

        // Criar modelo do usuário a partir da resposta
        final userData = responseData['user'];

        // Criar AddressModel a partir dos dados do backend
        final addressData = userData['endereco'] ?? userData['address'] ?? {};
        final address = AddressModel(
          street: addressData['street'] ?? '',
          number: addressData['number'] ?? '',
          complement: addressData['complement'],
          neighborhood: addressData['neighborhood'] ?? '',
          city: addressData['city'] ?? '',
          state: addressData['state'] ?? '',
          zipCode: addressData['zipCode'] ?? '',
        );

        final user = UserModel(
          id: userData['id'].toString(),
          name: userData['nome'] ?? userData['name'] ?? '',
          email: userData['email'],
          phone: userData['telefone'] ?? userData['phone'] ?? '',
          address: address,
          latitude: userData['latitude']?.toDouble() ?? 0.0,
          longitude: userData['longitude']?.toDouble() ?? 0.0,
          istore: userData['tipo'] == 'vendedor' || userData['istore'] == true,
        );

        await saveUser(user);
        AppLogger.info('💾 Usuário salvo no storage local');
        return user;
      } else if (response.statusCode == 401) {
        AppLogger.warning(
            '❌ Login falhou: Credenciais inválidas - Status: ${response.statusCode} - Email: $email');
        throw Exception('Email ou senha incorretos');
      } else if (response.statusCode == 404) {
        AppLogger.warning(
            '❌ Login falhou: Usuário não encontrado - Status: ${response.statusCode} - Email: $email');
        throw Exception('Usuário não encontrado');
      } else if (response.statusCode >= 500) {
        AppLogger.error(
            '💥 Erro do servidor no login - Status: ${response.statusCode} - Response: ${response.body}',
            response.body);
        throw Exception(
            'Erro interno do servidor. Tente novamente mais tarde.');
      } else {
        try {
          final errorData = json.decode(response.body);
          AppLogger.warning(
              '⚠️ Erro no login - Status: ${response.statusCode} - Mensagem: ${errorData['message']}');
          throw Exception(errorData['message'] ?? 'Erro no login');
        } catch (e) {
          AppLogger.error(
              '💥 Erro ao processar resposta do login - Status: ${response.statusCode} - Parse Error: $e',
              e);
          throw Exception('Erro no login: ${response.statusCode}');
        }
      }
    } catch (e) {
      AppLogger.error('💥 Erro ao fazer login - Email: $email', e);

      if (e.toString().contains('SocketException')) {
        throw Exception('Sem conexão com a internet. Verifique sua rede.');
      } else if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Timeout:')) {
        throw Exception('Conexão muito lenta. Tente novamente.');
      } else if (e.toString().contains('HandshakeException')) {
        throw Exception('Erro de segurança na conexão.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Resposta inválida do servidor.');
      }

      rethrow;
    }
  }

  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required AddressModel address,
    required double latitude,
    required double longitude,
    bool istore = false,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(AppConstants.registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nome': name, // Corrigido: 'name' -> 'nome'
          'email': email,
          'senha': password,
          'telefone': phone, // Corrigido: 'phone' -> 'telefone'
          'endereco': address.toJson(), // Corrigido: 'address' -> 'endereco'
          'latitude': latitude,
          'longitude': longitude,
          // Removido: 'istore' (não é esperado pelo backend)
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: Servidor demorou para responder');
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Salvar token JWT se fornecido
        final token = responseData['token'];
        if (token != null) {
          await _storage.write(AppConstants.tokenKey, token);
        }

        // Criar modelo do usuário a partir da resposta
        final userData = responseData['user'];
        final addressData = userData['endereco'] ?? userData['address'];

        final addressModel = AddressModel(
          street: addressData['street'] ?? '',
          number: addressData['number'] ?? '',
          complement: addressData['complement'],
          neighborhood: addressData['neighborhood'] ?? '',
          city: addressData['city'] ?? '',
          state: addressData['state'] ?? '',
          zipCode: addressData['zipCode'] ?? '',
        );

        final user = UserModel(
          id: userData['id'].toString(),
          name: userData['nome'] ?? userData['name'] ?? '',
          email: userData['email'],
          phone: userData['telefone'] ?? userData['phone'] ?? '',
          address: addressModel,
          latitude: userData['latitude']?.toDouble() ?? 0.0,
          longitude: userData['longitude']?.toDouble() ?? 0.0,
          istore: userData['tipo'] == 'vendedor' || userData['istore'] == true,
        );

        await saveUser(user);
        return user;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Dados inválidos');
      } else if (response.statusCode == 409) {
        throw Exception('Email já está em uso');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Erro interno do servidor. Tente novamente mais tarde.');
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Erro no cadastro');
        } catch (e) {
          throw Exception('Erro no cadastro: ${response.statusCode}');
        }
      }
    } catch (e) {
      AppLogger.error('Erro ao fazer cadastro', e);

      if (e.toString().contains('SocketException')) {
        throw Exception('Sem conexão com a internet. Verifique sua rede.');
      } else if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Timeout:')) {
        throw Exception('Conexão muito lenta. Tente novamente.');
      } else if (e.toString().contains('HandshakeException')) {
        throw Exception('Erro de segurança na conexão.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Resposta inválida do servidor.');
      }

      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = _storage.read(AppConstants.userKey);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar usuário do storage', e);
    }
    return null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _storage.write(AppConstants.userKey, user.toJson());
    } catch (e) {
      AppLogger.error('Erro ao salvar usuário', e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _storage.remove(AppConstants.userKey);
      await _storage.remove(AppConstants.tokenKey);
      await _storage.remove(AppConstants.cartKey);
      // Limpar credenciais salvas também
      await clearSavedCredentials();
    } catch (e) {
      AppLogger.error('Erro ao fazer logout', e);
      rethrow;
    }
  }

  /// Obtém o token JWT salvo no storage
  @override
  Future<String?> getToken() async {
    try {
      return _storage.read(AppConstants.tokenKey);
    } catch (e) {
      AppLogger.error('Erro ao obter token', e);
      return null;
    }
  }

  /// Salva o token JWT no storage
  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(AppConstants.tokenKey, token);
      // Salvar timestamp do login
      await _storage.write(
          'auth_timestamp', DateTime.now().millisecondsSinceEpoch);
      AppLogger.info('💾 Token salvo no storage');
    } catch (e) {
      AppLogger.error('Erro ao salvar token', e);
      rethrow;
    }
  }

  /// Verifica se o usuário está autenticado (tem token válido)
  @override
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  /// Obtém o timestamp do último login
  @override
  Future<DateTime?> getLastLoginTime() async {
    try {
      final timestamp = _storage.read('auth_timestamp');
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      AppLogger.error('❌ Erro ao obter timestamp do login', e);
      return null;
    }
  }

  /// Verifica se o token precisa ser renovado
  @override
  Future<bool> shouldRefreshToken() async {
    try {
      final timestamp = _storage.read('auth_timestamp');
      if (timestamp != null) {
        final loginTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final difference = now.difference(loginTime);

        // Renovar se passou mais de 7 dias
        return difference.inDays > 7;
      }
      return false;
    } catch (e) {
      AppLogger.error('❌ Erro ao verificar necessidade de renovação', e);
      return false;
    }
  }

  /// Salva as credenciais de login para uso futuro
  @override
  Future<void> saveCredentials(String email, String password) async {
    try {
      AppLogger.info('💾 [STORAGE] Salvando credenciais para: $email');

      // Criptografar a senha antes de salvar (usando base64 como exemplo simples)
      final encodedPassword = base64.encode(utf8.encode(password));

      await _storage.write('saved_email', email);
      await _storage.write('saved_password', encodedPassword);
      await _storage.write(
          'credentials_timestamp', DateTime.now().millisecondsSinceEpoch);

      // Verificar se foi salvo corretamente
      final savedEmail = _storage.read('saved_email');
      final savedPassword = _storage.read('saved_password');

      AppLogger.info(
          '💾 [STORAGE] Email salvo: ${savedEmail != null ? savedEmail : 'ERRO'}');
      AppLogger.info(
          '💾 [STORAGE] Password salvo: ${savedPassword != null ? 'presente' : 'ERRO'}');
      AppLogger.info('💾 Credenciais salvas para login automático');
    } catch (e) {
      AppLogger.error('❌ [STORAGE] Erro ao salvar credenciais', e);
      rethrow;
    }
  }

  /// Obtém as credenciais salvas
  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final email = _storage.read('saved_email');
      final encodedPassword = _storage.read('saved_password');

      if (email != null && encodedPassword != null) {
        // Descriptografar a senha
        final password = utf8.decode(base64.decode(encodedPassword));

        return {
          'email': email,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      AppLogger.error('❌ Erro ao obter credenciais salvas', e);
      return null;
    }
  }

  /// Limpa as credenciais salvas
  @override
  Future<void> clearSavedCredentials() async {
    try {
      await _storage.remove('saved_email');
      await _storage.remove('saved_password');
      await _storage.remove('credentials_timestamp');

      AppLogger.info('🗑️ Credenciais salvas removidas');
    } catch (e) {
      AppLogger.error('❌ Erro ao limpar credenciais salvas', e);
      rethrow;
    }
  }

  /// Verifica se existem credenciais salvas
  @override
  Future<bool> hasSavedCredentials() async {
    try {
      AppLogger.info('🔍 [STORAGE] Verificando credenciais salvas...');

      final email = _storage.read('saved_email');
      final password = _storage.read('saved_password');

      AppLogger.info(
          '🔍 [STORAGE] Email lido: ${email != null ? email : 'null'}');
      AppLogger.info(
          '🔍 [STORAGE] Password lido: ${password != null ? 'presente' : 'null'}');

      final hasCredentials = email != null && password != null;
      AppLogger.info('🔍 [STORAGE] Tem credenciais: $hasCredentials');

      return hasCredentials;
    } catch (e) {
      AppLogger.error('❌ [STORAGE] Erro ao verificar credenciais salvas', e);
      return false;
    }
  }
}
