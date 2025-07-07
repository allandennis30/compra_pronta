import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../../../core/utils/logger.dart';

class ProductListController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final RxList<ProductModel> _products = <ProductModel>[].obs;
  final RxList<ProductModel> _filteredProducts = <ProductModel>[].obs;
  final RxList<String> _favorites = <String>[].obs;
  final RxString _selectedCategory = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _isLoading = false.obs;

  List<ProductModel> get products => _filteredProducts;
  List<String> get favorites => _favorites;
  String get selectedCategory => _selectedCategory.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
    _loadFavorites();
  }

  void _loadProducts() async {
    _isLoading.value = true;
    
    try {
      final products = await _productRepository.getAll();
      _products.value = products;
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar produtos: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _loadFavorites() async {
    try {
      final favorites = await _productRepository.getFavorites();
      _favorites.value = favorites;
    } catch (e) {
      AppLogger.error('Erro ao carregar favoritos', e);
    }
  }

  void _applyFilters() {
    List<ProductModel> filtered = List.from(_products);
    
    // Filtrar por categoria
    if (_selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((product) => 
          product.category == _selectedCategory.value).toList();
    }
    
    // Filtrar por busca
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((product) =>
          product.name.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.value.toLowerCase())
      ).toList();
    }
    
    _filteredProducts.value = filtered;
  }

  void setCategory(String category) {
    _selectedCategory.value = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      await _productRepository.toggleFavorite(productId);
      _loadFavorites();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar favoritos: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    }
  }

  bool isFavorite(String productId) {
    return _favorites.contains(productId);
  }

  List<String> get categories {
    return ['', 'Frutas e Verduras', 'Laticínios', 'Bebidas', 'Higiene', 'Limpeza'];
  }
} 