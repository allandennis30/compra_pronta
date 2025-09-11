import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import '../../../core/repositories/base_repository.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/controllers/auth_controller.dart';

abstract class ProductRepository extends BaseRepository<ProductModel> {
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<String>> getFavorites();
  Future<void> toggleFavorite(String productId);
  Future<ProductModel?> getProductByBarcode(String barcode);
  Future<Map<String, dynamic>> getPublicProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
    String? vendor,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? sortAscending,
  });

  Future<Map<String, dynamic>> getAvailableFilters();
}

class ProductRepositoryImpl implements ProductRepository {
  final GetStorage _storage = GetStorage();

  String get _userFavoritesKey {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser;
    return currentUser != null
        ? '${AppConstants.favoritesKey}_${currentUser.id}'
        : AppConstants.favoritesKey;
  }

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      final result = await getPublicProducts(page: 1, limit: 1000);
      return result['products'] ?? [];
    } catch (e) {
      AppLogger.error('Erro ao carregar produtos', e);
      return [];
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    final products = await getAll();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    // Simular criação na API
    await Future.delayed(const Duration(milliseconds: 300));
    return item;
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    // Simular atualização na API
    await Future.delayed(const Duration(milliseconds: 300));
    return item;
  }

  @override
  Future<bool> delete(String id) async {
    // Simular exclusão na API
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    final products = await getAll();
    return products
        .where((product) =>
            (product.name?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (product.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final products = await getAll();
    if (category.isEmpty) {
      return products;
    }
    return products.where((product) => product.category == category).toList();
  }

  @override
  Future<List<String>> getFavorites() async {
    try {
      // Verificar se usuário está autenticado
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        AppLogger.error('Usuário não autenticado');
        return [];
      }

      final favorites = _storage.read(_userFavoritesKey);
      if (favorites is List) {
        return favorites.cast<String>();
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar favoritos', e);
    }
    return [];
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    try {
      // Verificar se usuário está autenticado
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        AppLogger.error('Usuário não autenticado');
        return;
      }

      final favorites = await getFavorites();
      if (favorites.contains(productId)) {
        favorites.remove(productId);
      } else {
        favorites.add(productId);
      }
      await _storage.write(_userFavoritesKey, favorites);
    } catch (e) {
      AppLogger.error('Erro ao salvar favoritos', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final products = await getAll();
    try {
      return products.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getPublicProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
    String? vendor,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? sortAscending,
  }) async {
    try {
      // Obter cidade do cliente atual
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;
      final clientCity = currentUser?.address.city ?? '';

      // Verificar dados do usuário
      AppLogger.info('🏠 Cliente atual: ${currentUser?.name ?? "null"}, Cidade: "$clientCity"');
      
      // Se não há usuário logado ou cidade, retornar lista vazia
      if (currentUser == null) {
        AppLogger.warning('⚠️ Usuário não logado, não é possível carregar produtos');
        return {
          'products': <ProductModel>[],
          'pagination': {
            'totalPages': 0,
            'totalItems': 0,
            'hasNextPage': false,
          },
        };
      }
      
      if (clientCity.isEmpty) {
        AppLogger.warning('⚠️ Cidade do cliente não configurada, não é possível carregar produtos');
        return {
          'products': <ProductModel>[],
          'pagination': {
            'totalPages': 0,
            'totalItems': 0,
            'hasNextPage': false,
          },
        };
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Adicionar cidade do cliente (obrigatório)
      if (clientCity.isNotEmpty) {
        queryParams['clientCity'] = clientCity;
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (vendor != null && vendor.isNotEmpty) {
        queryParams['vendor'] = vendor;
      }

      if (minPrice != null && minPrice > 0) {
        queryParams['minPrice'] = minPrice.toString();
      }

      if (maxPrice != null && maxPrice < 1000) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      if (sortAscending != null) {
        queryParams['sortAscending'] = sortAscending.toString();
      }

      final publicProductsEndpoint = await AppConstants.publicProductsEndpoint;
      final uri = Uri.parse(publicProductsEndpoint)
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['products'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'products': products,
          'pagination': data['pagination'],
        };
      } else {
        throw Exception('Falha ao carregar produtos: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar produtos públicos', e);
      rethrow;
    }
  }

  /// Obter filtros disponíveis (categorias e vendedores)
  @override
  Future<Map<String, dynamic>> getAvailableFilters() async {
    try {
      // Obter cidade do cliente atual
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;
      final clientCity = currentUser?.address.city ?? '';

      // Verificar dados do usuário nos filtros

      final queryParams = <String, String>{};

      // Adicionar cidade do cliente (obrigatório)
      if (clientCity.isNotEmpty) {
        queryParams['clientCity'] = clientCity;
      }

      final publicProductsFiltersEndpoint =
          await AppConstants.publicProductsFiltersEndpoint;
      final uri = Uri.parse(publicProductsFiltersEndpoint)
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Converter corretamente List<dynamic> para List<String>
        List<String> categories = [];
        List<String> vendors = [];

        if (data['categories'] is List) {
          categories = (data['categories'] as List)
              .where((item) => item != null)
              .map((item) => item.toString())
              .toList();
        }

        if (data['vendors'] is List) {
          vendors = (data['vendors'] as List)
              .where((item) => item != null)
              .map((item) => item.toString())
              .toList();
        }

        return {
          'categories': categories,
          'vendors': vendors,
        };
      } else {
        return {
          'categories': <String>[],
          'vendors': <String>[],
        };
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar filtros disponíveis', e);
      return {
        'categories': <String>[],
        'vendors': <String>[],
      };
    }
  }
}
