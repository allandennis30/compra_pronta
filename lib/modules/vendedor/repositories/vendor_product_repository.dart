import 'package:get_storage/get_storage.dart';
import '../../../core/repositories/base_repository.dart';
import '../../cliente/models/product_model.dart';
import '../../../core/utils/logger.dart';
import 'dart:io';
import 'dart:math';

abstract class VendedorProductRepository extends BaseRepository<ProductModel> {
  Future<ProductModel?> getProductByBarcode(String barcode);
  Future<String> saveProductImage(File imageFile);
}

class VendedorProductRepositoryImpl implements VendedorProductRepository {
  final GetStorage _storage = GetStorage();
  List<ProductModel>? _cachedProducts;
  bool _isInitialized = false;

  // Chave para armazenar os produtos do vendedor
  static const String _vendedorProductsKey = 'vendedor_products';

  // Carregar produtos salvos pelo vendedor
  List<ProductModel> _loadVendedorProducts() {
    try {
      final productsData = _storage.read(_vendedorProductsKey);
      if (productsData != null && productsData is List) {
        final products = <ProductModel>[];
        for (final item in productsData) {
          try {
            if (item is Map<String, dynamic>) {
              final product = ProductModel.fromJson(item);
              products.add(product);
            }
          } catch (e) {
            AppLogger.error('Erro ao converter produto: $item', e);
            // Continua para o próximo produto
          }
        }
        return products;
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar produtos do vendedor', e);
    }
    return [];
  }

  // Salvar produtos do vendedor
  Future<void> _saveVendedorProducts(List<ProductModel> products) async {
    try {
      final productsJson = products.map((product) => product.toJson()).toList();
      await _storage.write(_vendedorProductsKey, productsJson);
      _cachedProducts = List.from(
          products); // Cria uma cópia para evitar referências compartilhadas
    } catch (e) {
      AppLogger.error('Erro ao salvar produtos do vendedor', e);
      rethrow;
    }
  }

  // Inicializar o cache se necessário
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _cachedProducts = _loadVendedorProducts();
      _isInitialized = true;
    }
  }

  @override
  Future<List<ProductModel>> getAll() async {
    await _ensureInitialized();

    if (_cachedProducts != null) {
      return List.from(
          _cachedProducts!); // Retorna uma cópia para evitar modificações externas
    }

    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 500));

    // Carregar produtos salvos pelo vendedor
    final vendorProducts = _loadVendedorProducts();
    _cachedProducts = vendorProducts;

    return List.from(_cachedProducts!);
  }

  @override
  Future<ProductModel?> getById(String id) async {
    if (id.isEmpty) return null;

    final products = await getAll();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ProductModel> create(ProductModel item) async {
    if (item.id?.isEmpty ?? true) {
      throw ArgumentError('ID do produto não pode estar vazio');
    }

    // Simular criação na API
    await Future.delayed(Duration(milliseconds: 300));

    // Carregar produtos atuais
    final products = await getAll();

    // Verificar se já existe um produto com o mesmo ID
    final existingIndex =
        products.indexWhere((product) => product.id == item.id);
    if (existingIndex >= 0) {
      throw ArgumentError('Produto com ID ${item.id} já existe');
    }

    // Adicionar o novo produto
    products.add(item);

    // Salvar a lista atualizada
    await _saveVendedorProducts(products);

    return item;
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    if (item.id?.isEmpty ?? true) {
      throw ArgumentError('ID do produto não pode estar vazio');
    }

    // Simular atualização na API
    await Future.delayed(Duration(milliseconds: 300));

    // Carregar produtos atuais
    final products = await getAll();

    // Encontrar o índice do produto a ser atualizado
    final index = products.indexWhere((product) => product.id == item.id);

    if (index >= 0) {
      // Substituir o produto antigo pelo atualizado
      products[index] = item;

      // Salvar a lista atualizada
      await _saveVendedorProducts(products);
    } else {
      throw ArgumentError('Produto com ID ${item.id} não encontrado');
    }

    return item;
  }

  @override
  Future<bool> delete(String id) async {
    if (id.isEmpty) return false;

    // Simular exclusão na API
    await Future.delayed(Duration(milliseconds: 300));

    // Carregar produtos atuais
    final products = await getAll();

    // Remover o produto
    final initialLength = products.length;
    products.removeWhere((product) => product.id == id);

    // Salvar a lista atualizada se houve remoção
    if (products.length < initialLength) {
      await _saveVendedorProducts(products);
      return true;
    }

    return false;
  }

  @override
  Future<List<ProductModel>> search(String query) async {
    if (query.trim().isEmpty) {
      return await getAll();
    }

    final products = await getAll();
    final lowerQuery = query.toLowerCase().trim();

    return products
        .where((product) =>
            (product.name?.toLowerCase().contains(lowerQuery) ?? false) ||
            (product.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return null;

    final products = await getAll();
    try {
      return products
          .firstWhere((product) => product.barcode?.trim() == barcode.trim());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> saveProductImage(File imageFile) async {
    if (!await imageFile.exists()) {
      throw FileSystemException('Arquivo de imagem não existe', imageFile.path);
    }

    // Em uma implementação real, você faria upload da imagem para um servidor
    // e retornaria a URL da imagem
    // Aqui, vamos simular esse processo retornando uma URL fake

    await Future.delayed(Duration(milliseconds: 300));
    final random = Random().nextInt(1000);

    // Usar uma URL de imagem real em vez de placeholder
    return 'https://picsum.photos/500/500?random=$random';
  }

  // Método para limpar o cache (útil para testes ou quando necessário)
  void clearCache() {
    _cachedProducts = null;
    _isInitialized = false;
  }

  // Método para verificar se há produtos salvos
  Future<bool> hasProducts() async {
    await _ensureInitialized();
    return _cachedProducts?.isNotEmpty ?? false;
  }
}
