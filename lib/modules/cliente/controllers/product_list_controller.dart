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
  final RxBool _isLoadingMore = false.obs;

  // Paginação
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalItems = 0.obs;
  final RxBool _hasNextPage = false.obs;

  final RxBool _isInitialized = false.obs;

  // Scroll infinito
  final RxBool _hasReachedEnd = false.obs;

  // Novos filtros avançados
  final RxString _selectedVendor = ''.obs;
  final RxString _sortBy = 'recent'.obs;
  final RxBool _sortAscending = false.obs;
  final RxDouble _minPrice = 0.0.obs;
  final RxDouble _maxPrice = 1000.0.obs;
  final RxBool _onlyAvailable = true.obs;
  final RxBool _showFilters = false.obs;

  // Listas para filtros
  final RxList<String> _availableVendors = <String>[].obs;
  final RxList<String> _availableCategories = <String>[].obs;

  List<ProductModel> get products => _filteredProducts;
  List<String> get favorites => _favorites;
  String get selectedCategory => _selectedCategory.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalItems => _totalItems.value;
  bool get hasNextPage => _hasNextPage.value;
  bool get isInitialized => _isInitialized.value;
  bool get hasReachedEnd => _hasReachedEnd.value;

  // Getters para novos filtros
  String get selectedVendor => _selectedVendor.value;
  String get sortBy => _sortBy.value;
  bool get sortAscending => _sortAscending.value;
  double get minPrice => _minPrice.value;
  double get maxPrice => _maxPrice.value;
  bool get onlyAvailable => _onlyAvailable.value;
  bool get showFilters => _showFilters.value;
  List<String> get availableVendors => _availableVendors;
  List<String> get availableCategories => _availableCategories;

  // Verificar se há filtros ativos
  bool get hasActiveFilters {
    return _selectedCategory.value.isNotEmpty ||
        _selectedVendor.value.isNotEmpty ||
        _searchQuery.value.isNotEmpty ||
        _minPrice.value > 0.0 ||
        _maxPrice.value < 1000.0 ||
        _sortBy.value != 'recent';
  }

  // Contar produtos filtrados
  int get filteredProductsCount => _filteredProducts.length;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
    _loadFavorites();
    _loadAvailableFilters();
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _products.clear();
      _filteredProducts.clear();
    }

    if (_isLoading.value) return;

    if (refresh) {
      _isLoading.value = true;
    } else {
      _isLoadingMore.value = true;
    }

    try {
      final result = await _productRepository.getPublicProducts(
        page: _currentPage.value,
        limit: 10,
        category:
            _selectedCategory.value.isEmpty ? null : _selectedCategory.value,
        search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
        vendor: _selectedVendor.value.isEmpty ? null : _selectedVendor.value,
        minPrice: _minPrice.value > 0.0 ? _minPrice.value : null,
        maxPrice: _maxPrice.value < 1000.0 ? _maxPrice.value : null,
        sortBy: _sortBy.value,
        sortAscending: _sortAscending.value,
      );

      final newProducts = result['products'] as List<ProductModel>;
      final pagination = result['pagination'];

      if (refresh || _currentPage.value == 1) {
        _products.value = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      // Atualizar informações de paginação
      _totalPages.value = pagination['totalPages'] ?? 1;
      _totalItems.value = pagination['totalItems'] ?? 0;
      _hasNextPage.value = pagination['hasNextPage'] ?? false;

      // Verificar se chegou ao fim
      if (!_hasNextPage.value || newProducts.isEmpty) {
        _hasReachedEnd.value = true;
      }

      _applyFilters();
      _isInitialized.value = true;
    } catch (e) {
      AppLogger.error('Erro ao carregar produtos', e);
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  Future<void> loadNextPage() async {
    if (_hasNextPage.value && !_isLoadingMore.value && !_hasReachedEnd.value) {
      _currentPage.value++;
      await _loadProducts();
    }
  }

  Future<void> refreshProducts() async {
    _hasReachedEnd.value = false;
    await _loadProducts(refresh: true);
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _productRepository.getFavorites();
      _favorites.value = favorites;
    } catch (e) {
      AppLogger.error('Erro ao carregar favoritos', e);
    }
  }

  Future<void> _loadAvailableFilters() async {
    try {
      // Carregar categorias e vendedores disponíveis
      final result = await _productRepository.getAvailableFilters();
      _availableCategories.value = result['categories'] ?? [];
      _availableVendors.value = result['vendors'] ?? [];
    } catch (e) {
      AppLogger.error('Erro ao carregar filtros disponíveis', e);
    }
  }

  void _applyFilters() {
    // Para produtos públicos, os filtros são aplicados na API
    // então não precisamos filtrar localmente
    _filteredProducts.value = List.from(_products);
  }

  Future<void> setCategory(String category) async {
    _selectedCategory.value = category;
    _hasReachedEnd.value = false;
    await _loadProducts(refresh: true);
  }

  Future<void> setVendor(String vendor) async {
    _selectedVendor.value = vendor;
    _hasReachedEnd.value = false;
    await _loadProducts(refresh: true);
  }

  Future<void> setSorting(String sortBy, {bool ascending = false}) async {
    _sortBy.value = sortBy;
    _sortAscending.value = ascending;
    _hasReachedEnd.value = false;
    await _loadProducts(refresh: true);
  }

  Future<void> setPriceRange(double min, double max) async {
    _minPrice.value = min;
    _maxPrice.value = max;
    _hasReachedEnd.value = false;
    await _loadProducts(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _hasReachedEnd.value = false;
    // Debounce para busca
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (_searchQuery.value == query) {
        await _loadProducts(refresh: true);
      }
    });
  }

  void toggleFilters() {
    _showFilters.value = !_showFilters.value;
  }

  Future<void> clearAllFilters() async {
    _selectedCategory.value = '';
    _selectedVendor.value = '';
    _searchQuery.value = '';
    _minPrice.value = 0.0;
    _maxPrice.value = 1000.0;
    _sortBy.value = 'recent';
    _sortAscending.value = false;
    _hasReachedEnd.value = false;
    await _loadProducts(refresh: true);
  }

  Future<void> toggleFavorite(String productId, {BuildContext? context}) async {
    try {
      await _productRepository.toggleFavorite(productId);
      await _loadFavorites();
    } catch (e) {
      AppLogger.error('Erro ao atualizar favoritos', e);
    }
  }

  bool isFavorite(String productId) {
    return _favorites.contains(productId);
  }

  List<String> get categories {
    return ['', ..._availableCategories];
  }

  List<String> get vendors {
    return ['', ..._availableVendors];
  }

  List<Map<String, dynamic>> get sortOptions {
    return [
      {'value': 'recent', 'label': 'Mais Recentes'},
      {'value': 'name', 'label': 'Nome A-Z'},
      {'value': 'name_desc', 'label': 'Nome Z-A'},
      {'value': 'price', 'label': 'Menor Preço'},
      {'value': 'price_desc', 'label': 'Maior Preço'},
      {'value': 'popular', 'label': 'Mais Populares'},
    ];
  }

  String getSortLabel(String value) {
    final option = sortOptions.firstWhere(
      (option) => option['value'] == value,
      orElse: () => {'label': 'Mais Recentes'},
    );
    return option['label'];
  }
}
