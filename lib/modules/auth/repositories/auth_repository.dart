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
    } catch (e) {
      AppLogger.error('Erro ao fazer logout', e);
      rethrow;
    }
  }

  /// Obtém o token JWT salvo no storage
  Future<String?> getToken() async {
    try {
      return _storage.read(AppConstants.tokenKey);
    } catch (e) {
      AppLogger.error('Erro ao obter token', e);
      return null;
    }
  }

  /// Verifica se o usuário está autenticado (tem token válido)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }
}
