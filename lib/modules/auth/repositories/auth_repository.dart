import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../cliente/models/client_model.dart';

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

  // Recuperação de senha
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(
      {required String email,
      required String code,
      required String newPassword});
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

        // Criar modelo do usuário a partir da resposta
        final userData = responseData['user'];

        // Salvar token JWT
        final token = responseData['token'];
        if (token != null) {
          await _storage.write(AppConstants.tokenKey, token);
          AppLogger.info('💾 Token JWT salvo no storage');
        }

        // Salvar user_id para uso em outras partes do app
        final userId = userData['id']?.toString();
        if (userId != null) {
          await _storage.write('user_id', userId);
          AppLogger.info('💾 User ID salvo no storage: $userId');
        }

        // Salvar credenciais para login automático futuro
        await saveCredentials(email, password);

        // Verificar se é um cliente ou vendedor
        final isSeller = userData['isSeller'] == true ||
            userData['tipo'] == 'vendedor' ||
            userData['istore'] == true;

        UserModel user;

        if (isSeller) {
          // Criar AddressModel a partir dos dados do backend para vendedor
          final addressData = userData['endereco'] ?? userData['address'] ?? {};
          final address = AddressModel(
            street: addressData['rua'] ?? addressData['street'] ?? '',
            number: addressData['numero'] is int
                ? addressData['numero']
                : addressData['numero'] is String
                    ? int.tryParse(addressData['numero']) ?? 0
                    : addressData['number'] is int
                        ? addressData['number']
                        : addressData['number'] is String
                            ? int.tryParse(addressData['number']) ?? 0
                            : addressData['number'] ?? 0,
            complement: addressData['complemento'] ?? addressData['complement'],
            neighborhood:
                addressData['bairro'] ?? addressData['neighborhood'] ?? '',
            city: addressData['cidade'] ?? addressData['city'] ?? '',
            state: addressData['estado'] ?? addressData['state'] ?? '',
            zipCode: addressData['cep'] ?? addressData['zipCode'] ?? '',
          );

          user = UserModel(
            id: userData['id'].toString(),
            name: userData['nome'] ?? userData['name'] ?? '',
            email: userData['email'],
            phone: userData['telefone'] ?? userData['phone'] ?? '',
            address: address,
            latitude: userData['latitude']?.toDouble() ?? 0.0,
            longitude: userData['longitude']?.toDouble() ?? 0.0,
            istore: true,
          );
        } else {
          // Para cliente, usar ClientModel diretamente
          try {
            user = ClientModel.fromJson(userData);
          } catch (e) {
            AppLogger.error('💥 Erro ao criar ClientModel: $e', e);
            // Fallback para UserModel básico se falhar
            final addressData =
                userData['endereco'] ?? userData['address'] ?? {};
            final address = AddressModel(
              street: addressData['rua'] ?? addressData['street'] ?? '',
              number:
                  int.tryParse(addressData['numero']?.toString() ?? '0') ?? 0,
              complement:
                  addressData['complemento'] ?? addressData['complement'],
              neighborhood:
                  addressData['bairro'] ?? addressData['neighborhood'] ?? '',
              city: addressData['cidade'] ?? addressData['city'] ?? '',
              state: addressData['estado'] ?? addressData['state'] ?? '',
              zipCode: addressData['cep'] ?? addressData['zipCode'] ?? '',
            );

            user = UserModel(
              id: userData['id'].toString(),
              name: userData['nome'] ?? userData['name'] ?? '',
              email: userData['email'],
              phone: userData['telefone'] ?? userData['phone'] ?? '',
              address: address,
              latitude: userData['latitude']?.toDouble() ?? 0.0,
              longitude: userData['longitude']?.toDouble() ?? 0.0,
              istore: false,
            );
          }
        }

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

        // Salvar user_id para uso em outras partes do app
        final userId = userData['id']?.toString();
        if (userId != null) {
          await _storage.write('user_id', userId);
          AppLogger.info('💾 User ID salvo no storage: $userId');
        }
        final addressData = userData['endereco'] ?? userData['address'] ?? {};

        final addressModel = AddressModel(
          street: addressData['rua'] ?? addressData['street'] ?? '',
          number: addressData['numero'] ?? addressData['number'] ?? '',
          complement: addressData['complemento'] ?? addressData['complement'],
          neighborhood:
              addressData['bairro'] ?? addressData['neighborhood'] ?? '',
          city: addressData['cidade'] ?? addressData['city'] ?? '',
          state: addressData['estado'] ?? addressData['state'] ?? '',
          zipCode: addressData['cep'] ?? addressData['zipCode'] ?? '',
        );

        final user = UserModel(
          id: userData['id'].toString(),
          name: userData['nome'] ?? userData['name'] ?? '',
          email: userData['email'],
          phone: userData['telefone'] ?? userData['phone'] ?? '',
          address: addressModel,
          latitude: userData['latitude']?.toDouble() ?? 0.0,
          longitude: userData['longitude']?.toDouble() ?? 0.0,
          istore: userData['isSeller'] == true ||
              userData['tipo'] == 'vendedor' ||
              userData['istore'] == true,
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
      await _storage.remove('user_id');
      await _storage.remove(AppConstants.cartKey);
      // Limpar credenciais salvas também
      await clearSavedCredentials();
      AppLogger.info('💾 Logout realizado - dados limpos do storage');
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
      // Criptografar a senha antes de salvar (usando base64 como exemplo simples)
      final encodedPassword = base64.encode(utf8.encode(password));

      await _storage.write('saved_email', email);
      await _storage.write('saved_password', encodedPassword);
      await _storage.write(
          'credentials_timestamp', DateTime.now().millisecondsSinceEpoch);
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
      final email = _storage.read('saved_email');
      final password = _storage.read('saved_password');

      final hasCredentials = email != null && password != null;
      return hasCredentials;
    } catch (e) {
      AppLogger.error('❌ [STORAGE] Erro ao verificar credenciais salvas', e);
      return false;
    }
  }

  // ====== Recuperação de senha ======
  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.forgotPasswordEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        // Tente extrair mensagem do servidor
        String message = 'Falha ao solicitar recuperação';
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            message = data['error'] ?? data['message'] ?? response.body;
          } catch (_) {
            // Se não for JSON válido, use o próprio body como mensagem
            message = response.body;
          }
        }
        throw Exception(message);
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao solicitar recuperação de senha', e);
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.resetPasswordEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(
                {'email': email, 'code': code, 'newPassword': newPassword}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        String message = 'Falha ao redefinir senha';
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            message = data['error'] ?? data['message'] ?? response.body;
          } catch (_) {
            message = response.body;
          }
        }
        throw Exception(message);
      }
    } catch (e) {
      AppLogger.error('❌ Erro ao redefinir senha', e);
      rethrow;
    }
  }
}
