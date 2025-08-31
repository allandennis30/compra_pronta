import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../../core/repositories/base_repository.dart';
import '../../../constants/app_constants.dart';

class ProductApiRepository implements BaseRepository<ProductModel> {
  final http.Client _httpClient = http.Client();

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(AppConstants.listProductsEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar produtos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConstants.getProductEndpoint}/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao buscar produto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(AppConstants.createProductEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Erro ao criar produto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('${AppConstants.updateProductEndpoint}/${item.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Erro ao atualizar produto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('${AppConstants.deleteProductEndpoint}/$id'),
        headers: {
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
        Uri.parse(
            '${AppConstants.listProductsEndpoint}?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro na busca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
