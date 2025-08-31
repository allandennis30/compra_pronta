import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../repositories/vendedor_product_repository.dart';
import '../../cliente/models/product_model.dart';
import '../../../constants/app_constants.dart';
import '../../auth/repositories/auth_repository.dart';

class VendedorProductApiRepository implements VendedorProductRepository {
  final AuthRepository _authRepository;

  VendedorProductApiRepository({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authRepository.getToken();
    return {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      final headers = await _getHeaders();

      final response = await http
          .get(
            Uri.parse(AppConstants.listProductsEndpoint),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final productsData = responseData['products'] as List;

        final products =
            productsData.map((json) => ProductModel.fromJson(json)).toList();
        return products;
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Apenas vendedores podem acessar produtos.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao buscar produtos');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConstants.getProductEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final product = ProductModel.fromJson(responseData['product']);
        return product;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao buscar produto');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(AppConstants.createProductEndpoint),
        headers: headers,
        body: json.encode(() {
          final Map<String, dynamic> body = {
            'name': item.name,
            'description': item.description,
            'price': item.price,
            'category': item.category,
            'barcode': item.barcode,
            'stock': item.stock,
            'isSoldByWeight': item.isSoldByWeight,
            'isAvailable': item.isAvailable,
          };
          // Somente enviar pricePerKg quando vendido por peso
          if ((item.isSoldByWeight ?? false) && item.pricePerKg != null) {
            body['pricePerKg'] = item.pricePerKg;
          }
          // Enviar imageUrl apenas se não for vazia
          if ((item.imageUrl ?? '').trim().isNotEmpty) {
            body['imageUrl'] = item.imageUrl;
          }
          return body;
        }()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final createdProduct = ProductModel.fromJson(responseData['product']);
        return createdProduct;
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message']);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Dados inválidos');
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Apenas vendedores podem criar produtos.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao criar produto');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConstants.updateProductEndpoint}/${item.id}'),
        headers: headers,
        body: json.encode(() {
          final Map<String, dynamic> body = {
            'name': item.name,
            'description': item.description,
            'price': item.price,
            'category': item.category,
            'barcode': item.barcode,
            'stock': item.stock,
            'isSoldByWeight': item.isSoldByWeight,
            'isAvailable': item.isAvailable,
          };
          // Somente enviar pricePerKg quando vendido por peso
          if ((item.isSoldByWeight ?? false) && item.pricePerKg != null) {
            body['pricePerKg'] = item.pricePerKg;
          }
          // Enviar imageUrl apenas se não for vazia
          if ((item.imageUrl ?? '').trim().isNotEmpty) {
            body['imageUrl'] = item.imageUrl;
          }
          return body;
        }()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final updatedProduct = ProductModel.fromJson(responseData['product']);
        return updatedProduct;
      } else if (response.statusCode == 404) {
        throw Exception('Produto não encontrado');
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message']);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Dados inválidos');
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Apenas vendedores podem atualizar produtos.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao atualizar produto');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${AppConstants.deleteProductEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Apenas vendedores podem deletar produtos.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao deletar produto');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(
                '${AppConstants.listProductsEndpoint}?q=${Uri.encodeComponent(query)}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final productsData = responseData['products'] as List;

        final products =
            productsData.map((json) => ProductModel.fromJson(json)).toList();
        return products;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro na busca');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConstants.checkBarcodeEndpoint}/$barcode'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['available'] == true) {
          return null;
        } else {
          final productData = responseData['product'];
          final product = ProductModel.fromJson(productData);
          return product;
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Erro ao verificar código de barras');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> saveProductImage(File imageFile) async {
    // Este método não é usado na implementação da API
    // O upload de imagem é feito diretamente no formulário
    throw UnimplementedError('Use o serviço de imagem diretamente');
  }
}
