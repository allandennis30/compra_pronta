import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cliente/models/product_model.dart';
import '../repositories/vendedor_product_repository.dart';
import '../../../core/utils/logger.dart';

class VendedorProductListController extends GetxController {
  final VendedorProductRepository _repository;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> _allProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isSearching = false.obs;

  VendedorProductListController({required VendedorProductRepository repository})
      : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      AppLogger.info('🔄 [CONTROLLER] Iniciando carregamento de produtos');
      isLoading.value = true;
      hasError.value = false;

      AppLogger.info('📡 [CONTROLLER] Chamando repository.getAll()');
      final productList = await _repository.getAll();
      AppLogger.info(
          '✅ [CONTROLLER] Produtos recebidos: ${productList.length}');

      _allProducts.assignAll(productList);
      _applyFilters();
      AppLogger.info('✅ [CONTROLLER] Produtos carregados com sucesso');
    } catch (e) {
      AppLogger.error('💥 [CONTROLLER] Erro ao carregar produtos', e);
      hasError.value = true;
      errorMessage.value = 'Erro ao carregar produtos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;

      final success = await _repository.delete(productId);
      if (success) {
        // Remover da lista principal
        _allProducts.removeWhere((product) => product.id == productId);
        // Remover da lista filtrada
        products.removeWhere((product) => product.id == productId);

        Get.snackbar(
          'Produto removido',
          'Produto removido com sucesso',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Erro',
          'Não foi possível remover o produto',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao remover produto: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleProductAvailability(ProductModel product) async {
    try {
      final updatedProduct = product.copyWith(
        isAvailable: !(product.isAvailable ?? false),
      );

      await _repository.update(updatedProduct);

      // Atualizar na lista principal (_allProducts)
      final allProductsIndex =
          _allProducts.indexWhere((p) => p.id == product.id);
      if (allProductsIndex >= 0) {
        _allProducts[allProductsIndex] = updatedProduct;
      }

      // Atualizar na lista filtrada (products)
      final filteredIndex = products.indexWhere((p) => p.id == product.id);
      if (filteredIndex >= 0) {
        products[filteredIndex] = updatedProduct;
      }

      Get.snackbar(
        'Produto atualizado',
        'Disponibilidade atualizada com sucesso',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar disponibilidade: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByCategory(String? category) {
    selectedCategory.value = category ?? '';
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    var filteredProducts = _allProducts.toList();

    // Aplicar filtro de busca
    if (searchQuery.value.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return (product.name
                    ?.toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ??
                false) ||
            (product.description
                    ?.toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ??
                false);
      }).toList();
    }

    // Aplicar filtro de categoria
    if (selectedCategory.value.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.category == selectedCategory.value;
      }).toList();
    }

    products.assignAll(filteredProducts);
  }

  List<String> get availableCategories {
    return _allProducts
        .map((product) => product.category ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
      _applyFilters();
    }
  }
}
