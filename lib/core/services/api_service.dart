import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../utils/logger.dart';

class ApiService {
  static const String baseUrl =
      'https://backend-compra-pronta.onrender.com/api';
  final _storage = GetStorage();

  String? get _token {
    final token = _storage.read('auth_token');
    // Log apenas quando token não encontrado para debug
    if (token == null) {
      AppLogger.warning('🔍 [API] Token não encontrado');
    }
    return token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Erro na requisição PUT $endpoint', e);
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Erro na requisição DELETE $endpoint', e);
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          ...data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro na requisição',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      AppLogger.error('❌ [API] Erro ao processar resposta', e);
      return {
        'success': false,
        'message': 'Erro ao processar resposta do servidor',
        'statusCode': response.statusCode,
      };
    }
  }
}
