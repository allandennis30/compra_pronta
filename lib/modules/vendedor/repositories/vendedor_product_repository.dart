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

  // Chave para armazenar os produtos do vendedor
  static const String _vendedorProductsKey = 'vendedor_products';

  // Carregar produtos salvos pelo vendedor
  List<ProductModel> _loadVendedorProducts() {
    try {
      final productsData = _storage.read(_vendedorProductsKey);
      if (productsData != null && productsData is List) {
        return productsData.map((json) => ProductModel.fromJson(json)).toList();
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
      _cachedProducts = products;
    } catch (e) {
      AppLogger.error('Erro ao salvar produtos do vendedor', e);
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getAll() async {
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }

    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // Carregar produtos salvos pelo vendedor
    final vendorProducts = _loadVendedorProducts();
    if (vendorProducts.isNotEmpty) {
      _cachedProducts = vendorProducts;
      return _cachedProducts!;
    }

    // Sem mock: retornar lista vazia até que produtos sejam criados
    _cachedProducts = [];
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
    await Future.delayed(const Duration(milliseconds: 300));

    // Carregar produtos atuais
    final products = await getAll();

    // Adicionar o novo produto
    products.add(item);

    // Salvar a lista atualizada
    await _saveVendedorProducts(products);

    return item;
  }

  @override
  Future<ProductModel> update(ProductModel item) async {
    // Simular atualização na API
    await Future.delayed(const Duration(milliseconds: 300));

    // Carregar produtos atuais
    final products = await getAll();

    // Encontrar o índice do produto a ser atualizado
    final index = products.indexWhere((product) => product.id == item.id);

    if (index >= 0) {
      // Substituir o produto antigo pelo atualizado
      products[index] = item;

      // Salvar a lista atualizada
      await _saveVendedorProducts(products);
    }

    return item;
  }

  @override
  Future<bool> delete(String id) async {
    try {
      AppLogger.info('🗑️ Iniciando exclusão do produto: $id');

      // Simular exclusão na API
      await Future.delayed(const Duration(milliseconds: 300));

      // Carregar produtos atuais
      final products = await getAll();

      // Remover o produto pelo ID
      final initialLength = products.length;
      products.removeWhere((product) => product.id == id);

      // Salvar a lista atualizada se houve remoção
      if (products.length < initialLength) {
        await _saveVendedorProducts(products);
        AppLogger.success('✅ Produto excluído com sucesso: $id');
        return true;
      }

      AppLogger.warning('⚠️ Produto não encontrado para exclusão: $id');
      return false;
    } catch (e) {
      AppLogger.error('❌ Erro ao excluir produto: $id', e);
      rethrow;
    }
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
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final products = await getAll();
    try {
      return products.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> saveProductImage(File imageFile) async {
    try {
      AppLogger.info('📸 [LOCAL] Iniciando upload de imagem real');

      // Verificar se o arquivo existe
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      // Em uma implementação real, você faria upload da imagem para um servidor
      // e retornaria a URL da imagem
      // Por enquanto, vamos simular esse processo retornando uma URL fake

      await Future.delayed(const Duration(milliseconds: 300));
      final random = Random().nextInt(1000);

      // Usar uma URL de imagem real em vez de placeholder
      final fakeUrl = 'https://picsum.photos/500/500?random=$random';

      AppLogger.info('✅ [LOCAL] Imagem processada (simulada): $fakeUrl');
      return fakeUrl;
    } catch (e) {
      AppLogger.error('💥 [LOCAL] Erro ao processar imagem', e);
      rethrow;
    }
  }
}
