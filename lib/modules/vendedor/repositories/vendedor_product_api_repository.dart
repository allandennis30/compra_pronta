import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../repositories/vendedor_product_repository.dart';
import '../../cliente/models/product_model.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/repositories/auth_repository.dart';

class VendedorProductApiRepository implements VendedorProductRepository {
  final AuthRepository _authRepository;

  VendedorProductApiRepository({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authRepository.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      AppLogger.info('📋 [API] Buscando produtos do vendedor');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(AppConstants.listProductsEndpoint),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      AppLogger.info(
          '📡 [API] Resposta recebida - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final productsData = responseData['products'] as List;

        final products =
            productsData.map((json) => ProductModel.fromJson(json)).toList();
        AppLogger.success('✅ [API] Produtos carregados: ${products.length}');
        return products;
      } else if (response.statusCode == 401) {
        AppLogger.warning('❌ [API] Não autorizado - Token inválido');
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 403) {
        AppLogger.warning('❌ [API] Acesso negado - Usuário não é vendedor');
        throw Exception('Apenas vendedores podem acessar produtos.');
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao buscar produtos: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Erro ao buscar produtos');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao buscar produtos', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    try {
      AppLogger.info('🔍 [API] Buscando produto: $id');

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
        AppLogger.success('✅ [API] Produto encontrado: ${product.name}');
        return product;
      } else if (response.statusCode == 404) {
        AppLogger.warning('❌ [API] Produto não encontrado: $id');
        return null;
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao buscar produto: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Erro ao buscar produto');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao buscar produto', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    try {
      AppLogger.info('📦 [API] Criando produto: ${item.name}');

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(AppConstants.createProductEndpoint),
            headers: headers,
            body: json.encode({
              'name': item.name,
              'description': item.description,
              'price': item.price,
              'category': item.category,
              'barcode': item.barcode,
              'stock': item.stock,
              'isSoldByWeight': item.isSoldByWeight,
              'pricePerKg': item.pricePerKg,
              'imageUrl': item.imageUrl,
              'isAvailable': item.isAvailable,
            }),
          )
          .timeout(const Duration(seconds: 30));

      AppLogger.info(
          '📡 [API] Resposta recebida - Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final createdProduct = ProductModel.fromJson(responseData['product']);
        AppLogger.success(
            '✅ [API] Produto criado com sucesso: ${createdProduct.name}');
        return createdProduct;
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        AppLogger.warning(
            '❌ [API] Código de barras duplicado: ${errorData['message']}');
        throw Exception(errorData['message']);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        AppLogger.warning('❌ [API] Dados inválidos: ${errorData['details']}');
        throw Exception(
            'Dados inválidos: ${errorData['details']?.first?['msg'] ?? 'Verifique os campos'}');
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao criar produto: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Erro ao criar produto');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao criar produto', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    try {
      AppLogger.info('🔄 [API] Atualizando produto: ${item.name}');

      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.updateProductEndpoint}/${item.id}'),
            headers: headers,
            body: json.encode({
              'name': item.name,
              'description': item.description,
              'price': item.price,
              'category': item.category,
              'barcode': item.barcode,
              'stock': item.stock,
              'isSoldByWeight': item.isSoldByWeight,
              'pricePerKg': item.pricePerKg,
              'imageUrl': item.imageUrl,
              'isAvailable': item.isAvailable,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final updatedProduct = ProductModel.fromJson(responseData['product']);
        AppLogger.success(
            '✅ [API] Produto atualizado com sucesso: ${updatedProduct.name}');
        return updatedProduct;
      } else if (response.statusCode == 404) {
        AppLogger.warning('❌ [API] Produto não encontrado: ${item.id}');
        throw Exception('Produto não encontrado');
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        AppLogger.warning(
            '❌ [API] Código de barras duplicado: ${errorData['message']}');
        throw Exception(errorData['message']);
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao atualizar produto: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Erro ao atualizar produto');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao atualizar produto', e);
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      AppLogger.info('🗑️ [API] Deletando produto: $id');

      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${AppConstants.deleteProductEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        AppLogger.success('✅ [API] Produto deletado com sucesso: $id');
        return true;
      } else if (response.statusCode == 404) {
        AppLogger.warning('❌ [API] Produto não encontrado: $id');
        return false;
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao deletar produto: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Erro ao deletar produto');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao deletar produto', e);
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    try {
      AppLogger.info('🔍 [API] Buscando produtos: $query');

      final allProducts = await getAll();
      return allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao buscar produtos', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      AppLogger.info('🔍 [API] Verificando código de barras: $barcode');

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
          AppLogger.info('✅ [API] Código de barras disponível: $barcode');
          return null;
        } else {
          final productData = responseData['product'];
          final product = ProductModel.fromJson(productData);
          AppLogger.warning(
              '❌ [API] Código de barras já existe: ${product.name}');
          return product;
        }
      } else {
        final errorData = json.decode(response.body);
        AppLogger.error(
            '❌ [API] Erro ao verificar código de barras: ${errorData['message']}');
        throw Exception(
            errorData['message'] ?? 'Erro ao verificar código de barras');
      }
    } catch (e) {
      AppLogger.error('💥 [API] Erro ao verificar código de barras', e);
      rethrow;
    }
  }

  @override
  Future<String> saveProductImage(File imageFile) async {
    // Em uma implementação real, você faria upload da imagem para um servidor
    // e retornaria a URL da imagem
    // Por enquanto, vamos simular esse processo
    AppLogger.info('📸 [API] Simulando upload de imagem');

    await Future.delayed(const Duration(milliseconds: 500));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://via.placeholder.com/500x500.png?text=Product+Image+$timestamp';
  }
}
