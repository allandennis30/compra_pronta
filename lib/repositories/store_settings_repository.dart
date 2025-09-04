import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../core/utils/logger.dart';

class StoreSettingsRepository {
  final AuthRepository _authRepository = AuthRepositoryImpl();
  final String _baseUrl = AppConstants.baseUrl;

  /// Busca as configurações da loja do vendedor autenticado
  Future<Map<String, dynamic>?> getStoreSettings() async {
    try {
      print('🔍 [STORE_SETTINGS_REPO] Iniciando busca de configurações...');
      final token = await _authRepository.getToken();
      print(
          '🔍 [STORE_SETTINGS_REPO] Token obtido: ${token != null ? 'SIM' : 'NÃO'}');
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/store-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 [STORE_SETTINGS_REPO] Status code: ${response.statusCode}');
      print('🔍 [STORE_SETTINGS_REPO] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 [STORE_SETTINGS_REPO] Dados decodificados: $data');

        // Verificar se a resposta tem o formato esperado
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          print(
              '🔍 [STORE_SETTINGS_REPO] Resposta não tem formato esperado: $data');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('🔍 [STORE_SETTINGS_REPO] Configurações não encontradas (404)');
        return null; // Configurações não encontradas
      } else if (response.statusCode == 403) {
        final error = json.decode(response.body);
        print('🔍 [STORE_SETTINGS_REPO] Acesso negado (403): $error');
        throw Exception(
            'Apenas vendedores podem acessar configurações da loja');
      } else {
        final error = json.decode(response.body);
        print('🔍 [STORE_SETTINGS_REPO] Erro na resposta: $error');
        throw Exception(error['message'] ?? 'Erro ao buscar configurações');
      }
    } catch (e) {
      print('Erro ao buscar configurações da loja: $e');
      rethrow;
    }
  }

  /// Salva ou atualiza as configurações da loja
  Future<Map<String, dynamic>> saveStoreSettings(
      Map<String, dynamic> settings) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      // Log do payload enviado
      try {
        print('📝 [STORE_SETTINGS_REPO] Payload POST /api/store-settings:');
        print(const JsonEncoder.withIndent('  ').convert(settings));
      } catch (_) {}

      final response = await http.post(
        Uri.parse('$_baseUrl/api/store-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(settings),
      );

      print('🔍 [STORE_SETTINGS_REPO] POST status: ${response.statusCode}');
      print('🔍 [STORE_SETTINGS_REPO] POST body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar se a resposta tem o formato esperado
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          print(
              '🔍 [STORE_SETTINGS_REPO] Resposta não tem formato esperado: $data');
          throw Exception('Resposta inválida do servidor');
        }
      } else if (response.statusCode == 403) {
        // 403: Acesso negado
        throw Exception('Apenas vendedores podem configurar a loja');
      } else {
        // Tentar extrair erro detalhado
        try {
          final errObj = json.decode(response.body);
          throw Exception(errObj['message'] ?? 'Erro ao salvar configurações');
        } catch (_) {
          throw Exception(
              'Erro ao salvar configurações (status ${response.statusCode})');
        }
      }
    } catch (e) {
      print('Erro ao salvar configurações da loja: $e');
      rethrow;
    }
  }

  /// Atualiza campos específicos das configurações
  Future<Map<String, dynamic>> updateStoreSettings(
      Map<String, dynamic> settings) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      // Log do payload enviado
      try {
        print('📝 [STORE_SETTINGS_REPO] Payload PUT /api/store-settings:');
        print(const JsonEncoder.withIndent('  ').convert(settings));
      } catch (_) {}

      final response = await http.put(
        Uri.parse('$_baseUrl/api/store-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(settings),
      );

      print('🔍 [STORE_SETTINGS_REPO] PUT status: ${response.statusCode}');
      print('🔍 [STORE_SETTINGS_REPO] PUT body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar se a resposta tem o formato esperado
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          print(
              '🔍 [STORE_SETTINGS_REPO] Resposta não tem formato esperado: $data');
          throw Exception('Resposta inválida do servidor');
        }
      } else if (response.statusCode == 403) {
        // 403: Acesso negado
        throw Exception('Apenas vendedores podem configurar a loja');
      } else {
        try {
          final errObj = json.decode(response.body);
          throw Exception(
              errObj['message'] ?? 'Erro ao atualizar configurações');
        } catch (_) {
          throw Exception(
              'Erro ao atualizar configurações (status ${response.statusCode})');
        }
      }
    } catch (e) {
      print('Erro ao atualizar configurações da loja: $e');
      rethrow;
    }
  }

  /// Busca configurações públicas de todas as lojas ativas
  Future<List<Map<String, dynamic>>> getPublicStoreSettings({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final uri = Uri.parse('$_baseUrl/api/store-settings/public').replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar se a resposta tem o formato esperado
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          print(
              '🔍 [STORE_SETTINGS_REPO] Resposta não tem formato esperado: $data');
          throw Exception('Resposta inválida do servidor');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao buscar lojas');
      }
    } catch (e) {
      print('Erro ao buscar configurações públicas das lojas: $e');
      rethrow;
    }
  }

  /// Busca configurações de uma loja específica (público)
  Future<Map<String, dynamic>?> getStoreSettingsById(String sellerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/store-settings/$sellerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar se a resposta tem o formato esperado
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          print(
              '🔍 [STORE_SETTINGS_REPO] Resposta não tem formato esperado: $data');
          return null;
        }
      } else if (response.statusCode == 404) {
        return null; // Loja não encontrada
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao buscar loja');
      }
    } catch (e) {
      print('Erro ao buscar configurações da loja: $e');
      rethrow;
    }
  }

  /// Busca apenas a política de entrega pública da loja
  Future<Map<String, dynamic>?> getStorePolicy(String sellerId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/store-settings/$sellerId/policy');
      AppLogger.debug('[PolicyAPI] GET ' + uri.toString());
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      AppLogger.debug('[PolicyAPI] status=' + response.statusCode.toString());
      AppLogger.debug('[PolicyAPI] body=' + response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['policy'] != null) {
          return Map<String, dynamic>.from(data['policy']);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null; // Política não encontrada
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Erro ao buscar política de entrega');
      }
    } catch (e) {
      AppLogger.error('Erro ao buscar política de entrega', e);
      rethrow;
    }
  }
}
