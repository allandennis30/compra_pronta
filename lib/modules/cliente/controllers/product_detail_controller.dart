import 'package:get/get.dart';
import '../models/product_model.dart';
import 'cart_controller.dart';

class ProductDetailController extends GetxController {
  final Rx<ProductModel?> _product = Rx<ProductModel?>(null);
  final RxInt _quantity = 1.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isFavorite = false.obs;

  ProductModel? get product => _product.value;
  int get quantity => _quantity.value;
  bool get isLoading => _isLoading.value;
  bool get isFavorite => _isFavorite.value;

  @override
  void onInit() {
    super.onInit();
    _loadProductFromArguments();
  }

  void _loadProductFromArguments() {
    final arguments = Get.arguments;
    if (arguments is ProductModel) {
      _product.value = arguments;
      _checkIfFavorite();
    }
  }

  void _checkIfFavorite() {
    // TODO: Implementar verificação se produto está nos favoritos
    // Por enquanto, valor padrão é false
    _isFavorite.value = false;
  }

  void incrementQuantity() {
    if (_quantity.value < (product?.stock ?? 0)) {
      _quantity.value++;
    }
  }

  void decrementQuantity() {
    if (_quantity.value > 1) {
      _quantity.value--;
    }
  }

  void setQuantity(int newQuantity) {
    if (newQuantity >= 1 && newQuantity <= (product?.stock ?? 0)) {
      _quantity.value = newQuantity;
    }
  }

  void toggleFavorite() {
    _isFavorite.value = !_isFavorite.value;
    // TODO: Implementar persistência dos favoritos
    Get.snackbar(
      _isFavorite.value ? 'Adicionado aos favoritos' : 'Removido dos favoritos',
      product?.name ?? '',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addToCart() {
    if (product == null) return;

    try {
      final cartController = Get.find<CartController>();
      
      for (int i = 0; i < _quantity.value; i++) {
        cartController.addItem(product!);
      }

      Get.snackbar(
        'Produto adicionado',
        '${_quantity.value}x ${product!.name} adicionado ao carrinho',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reset quantity after adding to cart
      _quantity.value = 1;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível adicionar o produto ao carrinho',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void goToCart() {
    Get.toNamed('/cliente/carrinho');
  }

  void shareProduct() {
    // TODO: Implementar compartilhamento do produto
    Get.snackbar(
      'Compartilhar',
      'Funcionalidade em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  double get totalPrice => (product?.price ?? 0.0) * _quantity.value;

  bool get canAddToCart => 
      product != null && 
      product!.isAvailable && 
      product!.stock > 0 && 
      _quantity.value <= product!.stock;
}