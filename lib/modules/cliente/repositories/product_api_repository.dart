import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../../core/repositories/base_repository.dart';

class ProductApiRepository implements BaseRepository<ProductModel> {
  static const String baseUrl = 'https://api.supermercado.com/v1';
  static const String apiKey = 'your_api_key_here';
  
  final http.Client _httpClient = http.Client();

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar produtos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Falha ao carregar produto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Falha ao criar produto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/products/${item.id}'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Falha ao atualizar produto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/products/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha na busca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Métodos específicos para produtos
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/products?category=${Uri.encodeComponent(category)}'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar produtos por categoria: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/products/barcode/$barcode'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Falha ao buscar produto por código de barras: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  void dispose() {
    _httpClient.close();
  }
} 