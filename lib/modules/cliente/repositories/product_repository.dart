import 'package:get_storage/get_storage.dart';
import '../../../core/repositories/base_repository.dart';
import '../models/product_model.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

abstract class ProductRepository extends BaseRepository<ProductModel> {
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<String>> getFavorites();
  Future<void> toggleFavorite(String productId);
  Future<ProductModel?> getProductByBarcode(String barcode);
}

class ProductRepositoryImpl implements ProductRepository {
  final GetStorage _storage = GetStorage();
  List<ProductModel>? _cachedProducts;

  String get _userFavoritesKey {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser;
    return currentUser != null
        ? '${AppConstants.favoritesKey}_${currentUser.id}'
        : AppConstants.favoritesKey;
  }

  @override
  Future<List<ProductModel>> getAll() async {
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }

    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 500));

    _cachedProducts = AppConstants.mockProducts
        .map((json) => ProductModel.fromJson(json))
        .toList();

    return _cachedProducts!;
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
    await Future.delayed(Duration(milliseconds: 300));
    return item;
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    // Simular atualização na API
    await Future.delayed(Duration(milliseconds: 300));
    return item;
  }

  @override
  Future<bool> delete(String id) async {
    // Simular exclusão na API
    await Future.delayed(Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    final products = await getAll();
    return products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()))
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
}
