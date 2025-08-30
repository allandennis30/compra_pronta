import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../cliente/models/product_model.dart';
import '../../../core/repositories/base_repository.dart';
import '../../../core/services/supabase_image_service.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/controllers/auth_controller.dart';

/// Repositório que integra produtos com o serviço de imagens do Supabase
class VendedorProductSupabaseRepository
    implements BaseRepository<ProductModel> {
  final SupabaseImageService _imageService = SupabaseImageService();
  final AuthController _authController = Get.find<AuthController>();

  /// Headers para requisições autenticadas
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authController.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      AppLogger.info('📦 [SUPABASE] Buscando todos os produtos...');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(AppConstants.listProductsEndpoint),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['products'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();

        AppLogger.success(
            '✅ [SUPABASE] ${products.length} produtos carregados');
        return products;
      } else {
        throw Exception('Erro ao carregar produtos: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao carregar produtos', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    try {
      AppLogger.info('🔍 [SUPABASE] Buscando produto: $id');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConstants.getProductEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final product = ProductModel.fromJson(data['product']);
        AppLogger.success('✅ [SUPABASE] Produto encontrado: ${product.name}');
        return product;
      } else if (response.statusCode == 404) {
        AppLogger.warning('⚠️ [SUPABASE] Produto não encontrado: $id');
        return null;
      } else {
        throw Exception('Erro ao buscar produto: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao buscar produto', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    try {
      AppLogger.info('🆕 [SUPABASE] Criando produto: ${item.name}');

      // 1. Se há uma imagem selecionada, fazer upload primeiro
      String? finalImageUrl;
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
        AppLogger.info(
            '📸 [SUPABASE] Produto já tem URL de imagem: ${item.imageUrl}');
        finalImageUrl = item.imageUrl;
      }

      // 2. Criar o produto no backend
      final headers = await _getHeaders();
      final productData = {
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category,
        'barcode': item.barcode,
        'stock': item.stock,
        'isSoldByWeight': item.isSoldByWeight,
        'isAvailable': item.isAvailable,
        if (item.pricePerKg != null) 'pricePerKg': item.pricePerKg,
        if (finalImageUrl != null) 'imageUrl': finalImageUrl,
      };

      final response = await http
          .post(
            Uri.parse(AppConstants.createProductEndpoint),
            headers: headers,
            body: json.encode(productData),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final createdProduct = ProductModel.fromJson(data['product']);
        AppLogger.success(
            '✅ [SUPABASE] Produto criado: ${createdProduct.name}');
        return createdProduct;
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message']);
      } else {
        throw Exception('Erro ao criar produto: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao criar produto', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    try {
      AppLogger.info('✏️ [SUPABASE] Atualizando produto: ${item.name}');

      // 1. Se há uma nova imagem, fazer upload
      String? finalImageUrl;
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
        AppLogger.info(
            '📸 [SUPABASE] Produto tem nova imagem: ${item.imageUrl}');
        finalImageUrl = item.imageUrl;
      }

      // 2. Atualizar o produto no backend
      final headers = await _getHeaders();
      final productData = {
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category,
        'barcode': item.barcode,
        'stock': item.stock,
        'isSoldByWeight': item.isSoldByWeight,
        'isAvailable': item.isAvailable,
        if (item.pricePerKg != null) 'pricePerKg': item.pricePerKg,
        if (finalImageUrl != null) 'imageUrl': finalImageUrl,
      };

      final response = await http
          .put(
            Uri.parse('${AppConstants.updateProductEndpoint}/${item.id}'),
            headers: headers,
            body: json.encode(productData),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedProduct = ProductModel.fromJson(data['product']);
        AppLogger.success(
            '✅ [SUPABASE] Produto atualizado: ${updatedProduct.name}');
        return updatedProduct;
      } else {
        throw Exception('Erro ao atualizar produto: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao atualizar produto', e);
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      AppLogger.info('🗑️ [SUPABASE] Deletando produto: $id');

      // 1. Buscar o produto para obter a URL da imagem
      final product = await getById(id);
      if (product?.imageUrl != null && product!.imageUrl!.isNotEmpty) {
        AppLogger.info(
            '📸 [SUPABASE] Removendo imagem do produto: ${product.imageUrl}');
        await _imageService.deleteImage(product.imageUrl!);
      }

      // 2. Deletar o produto no backend
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${AppConstants.deleteProductEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        AppLogger.success('✅ [SUPABASE] Produto deletado: $id');
        return true;
      } else {
        throw Exception('Erro ao deletar produto: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao deletar produto', e);
      rethrow;
    }
  }

  /// Upload de imagem para um produto
  Future<String> uploadProductImage(File imageFile) async {
    try {
      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      AppLogger.info(
          '📸 [SUPABASE] Iniciando upload de imagem para produto...');

      // Comprimir imagem se necessário
      final compressedImage =
          await _imageService.compressImageIfNeeded(imageFile);

      // Fazer upload
      final imageUrl =
          await _imageService.uploadImage(compressedImage, currentUser.id!);

      AppLogger.success('✅ [SUPABASE] Imagem do produto enviada: $imageUrl');
      return imageUrl;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao fazer upload da imagem', e);
      rethrow;
    }
  }

  /// Atualizar imagem de um produto
  Future<String> updateProductImage(File newImage, String? oldImageUrl) async {
    try {
      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      AppLogger.info('🔄 [SUPABASE] Atualizando imagem do produto...');

      // Comprimir nova imagem
      final compressedImage =
          await _imageService.compressImageIfNeeded(newImage);

      // Atualizar imagem
      final newImageUrl = await _imageService.updateImage(
          compressedImage, currentUser.id!, oldImageUrl);

      AppLogger.success(
          '✅ [SUPABASE] Imagem do produto atualizada: $newImageUrl');
      return newImageUrl;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao atualizar imagem do produto', e);
      rethrow;
    }
  }

  /// Remover imagem de um produto
  Future<bool> removeProductImage(String imageUrl) async {
    try {
      AppLogger.info('🗑️ [SUPABASE] Removendo imagem do produto: $imageUrl');

      final success = await _imageService.deleteImage(imageUrl);

      if (success) {
        AppLogger.success('✅ [SUPABASE] Imagem do produto removida');
      } else {
        AppLogger.warning('⚠️ [SUPABASE] Não foi possível remover a imagem');
      }

      return success;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao remover imagem do produto', e);
      return false;
    }
  }

  /// Listar imagens de um produto
  Future<List<String>> listProductImages(String productId) async {
    try {
      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      AppLogger.info('📋 [SUPABASE] Listando imagens do produto: $productId');

      final images = await _imageService.listUserImages(currentUser.id!);

      // Filtrar apenas imagens relacionadas ao produto específico
      final productImages =
          images.where((url) => url.contains(productId)).toList();

      AppLogger.success(
          '✅ [SUPABASE] ${productImages.length} imagens encontradas para o produto');
      return productImages;
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao listar imagens do produto', e);
      return [];
    }
  }

  /// Verificar se uma imagem existe
  Future<bool> productImageExists(String imageUrl) async {
    try {
      return await _imageService.imageExists(imageUrl);
    } catch (e) {
      AppLogger.error(
          '💥 [SUPABASE] Erro ao verificar existência da imagem', e);
      return false;
    }
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    try {
      AppLogger.info('🔍 [SUPABASE] Buscando produtos: $query');

      final allProducts = await getAll();
      return allProducts
          .where((product) =>
              (product.name?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (product.description
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
          .toList();
    } catch (e) {
      AppLogger.error('💥 [SUPABASE] Erro ao buscar produtos', e);
      rethrow;
    }
  }
}
