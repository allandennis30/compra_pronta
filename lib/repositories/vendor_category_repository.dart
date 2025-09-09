import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vendor_category.dart';
import '../constants/app_constants.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../utils/logger.dart';

class VendorCategoryRepository {
  final AuthRepository _authRepository;

  VendorCategoryRepository(this._authRepository);

  Future<String> get _baseUrl async => '${await AppConstants.baseUrl}/api/vendor-categories';

  /// Buscar todas as categorias do vendedor logado
  Future<List<VendorCategory>> getVendorCategories() async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final baseUrl = await _baseUrl;
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['categories'] ?? [];
        
        return categoriesJson
            .map((json) => VendorCategory.fromJson(json))
            .toList();
      } else if (response.statusCode == 403) {
        throw Exception('Apenas vendedores podem acessar categorias');
      } else {
        throw Exception('Erro ao carregar categorias: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Erro no VendorCategoryRepository.getVendorCategories: $e');
      rethrow;
    }
  }

  /// Criar nova categoria
  Future<VendorCategory> createVendorCategory(String name) async {
    AppLogger.info('🌐 [REPO_CREATE_CATEGORY] Iniciando criação no repository: "$name"');
    try {
      // Obter token de autenticação
      AppLogger.info('🔑 [REPO_CREATE_CATEGORY] Obtendo token de autenticação');
      final token = await _authRepository.getToken();
      if (token == null) {
        AppLogger.error('❌ [REPO_CREATE_CATEGORY] Token não encontrado');
        throw Exception('Token de autenticação não encontrado');
      }
      AppLogger.info('✅ [REPO_CREATE_CATEGORY] Token obtido com sucesso');

      AppLogger.info('📡 [REPO_CREATE_CATEGORY] Fazendo requisição POST para: $_baseUrl');
      AppLogger.info('📝 [REPO_CREATE_CATEGORY] Payload: {"name": "$name"}');
      
      final baseUrl = await _baseUrl;
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
        }),
      );

      AppLogger.info('📊 [REPO_CREATE_CATEGORY] Status da resposta: ${response.statusCode}');
      AppLogger.info('📄 [REPO_CREATE_CATEGORY] Corpo da resposta: ${response.body}');

      if (response.statusCode == 201) {
        AppLogger.info('✅ [REPO_CREATE_CATEGORY] Categoria criada com sucesso');
        final data = json.decode(response.body);
        AppLogger.info('📋 [REPO_CREATE_CATEGORY] Dados da categoria: ${data['category']}');
        final category = VendorCategory.fromJson(data['category']);
        AppLogger.info('🎯 [REPO_CREATE_CATEGORY] Categoria mapeada: ${category.toJson()}');
        return category;
      } else if (response.statusCode == 409) {
        AppLogger.warning('⚠️ [REPO_CREATE_CATEGORY] Categoria já existe (409)');
        throw Exception('Categoria já existe');
      } else if (response.statusCode == 403) {
        AppLogger.error('🚫 [REPO_CREATE_CATEGORY] Acesso negado (403)');
        throw Exception('Acesso negado');
      } else if (response.statusCode == 400) {
        AppLogger.error('❌ [REPO_CREATE_CATEGORY] Dados inválidos (400)');
        final data = json.decode(response.body);
        final errors = data['errors'] as List?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.first['msg'] ?? 'Dados inválidos');
        }
        throw Exception(data['message'] ?? 'Dados inválidos');
      } else {
        AppLogger.error('💥 [REPO_CREATE_CATEGORY] Erro inesperado: ${response.statusCode}');
        throw Exception('Erro inesperado: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('💥 [REPO_CREATE_CATEGORY] Erro capturado: $e');
      AppLogger.error('📊 [REPO_CREATE_CATEGORY] Tipo do erro: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Atualizar categoria do vendedor
  Future<VendorCategory> updateVendorCategory(String id, String name) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final baseUrl = await _baseUrl;
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VendorCategory.fromJson(data['category']);
      } else if (response.statusCode == 404) {
        throw Exception('Categoria não encontrada');
      } else if (response.statusCode == 409) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Categoria já existe');
      } else if (response.statusCode == 403) {
        throw Exception('Apenas vendedores podem atualizar categorias');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        final errors = data['errors'] as List?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.first['msg'] ?? 'Dados inválidos');
        }
        throw Exception(data['message'] ?? 'Dados inválidos');
      } else {
        throw Exception('Erro ao atualizar categoria: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Erro no VendorCategoryRepository.updateVendorCategory: $e');
      rethrow;
    }
  }

  /// Deletar categoria do vendedor
  Future<void> deleteVendorCategory(String id) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final baseUrl = await _baseUrl;
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return; // Sucesso
      } else if (response.statusCode == 404) {
        throw Exception('Categoria não encontrada');
      } else if (response.statusCode == 409) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Categoria está sendo usada por produtos');
      } else if (response.statusCode == 403) {
        throw Exception('Apenas vendedores podem deletar categorias');
      } else {
        throw Exception('Erro ao deletar categoria: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Erro no VendorCategoryRepository.deleteVendorCategory: $e');
      rethrow;
    }
  }
}