import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import 'cart_controller.dart';
import '../../../core/utils/snackbar_utils.dart';

class ProductDetailController extends GetxController {
  final Rx<ProductModel?> _product = Rx<ProductModel?>(null);
  final RxInt _quantity = 1.obs;
  final RxDouble _weight = 0.5.obs; // Peso inicial de 0.5kg
  final RxBool _isLoading = false.obs;
  final RxBool _isFavorite = false.obs;

  ProductModel? get product => _product.value;
  int get quantity => _quantity.value;
  double get weight => _weight.value;
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
    if (product?.isSoldByWeight == true) {
      _weight.value += 0.1; // Incrementa 0.1kg
    } else {
      if (_quantity.value < (product?.stock ?? 0)) {
        _quantity.value++;
      }
    }
  }

  void decrementQuantity() {
    if (product?.isSoldByWeight == true) {
      if (_weight.value > 0.1) {
        _weight.value -= 0.1; // Decrementa 0.1kg
        if (_weight.value < 0.1) {
          _weight.value = 0.1; // Peso mínimo de 0.1kg
        }
      }
    } else {
      if (_quantity.value > 1) {
        _quantity.value--;
      }
    }
  }

  void setQuantity(int newQuantity) {
    if (newQuantity >= 1 && newQuantity <= (product?.stock ?? 0)) {
      _quantity.value = newQuantity;
    }
  }

  void setWeight(double newWeight) {
    if (newWeight >= 0.1) {
      _weight.value = newWeight;
    }
  }

  void toggleFavorite(BuildContext context) {
    _isFavorite.value = !_isFavorite.value;
    // TODO: Implementar persistência dos favoritos
    SnackBarUtils.showSuccess(
      context,
      _isFavorite.value ? 'Adicionado aos favoritos' : 'Removido dos favoritos',
    );
  }

  void addToCart(BuildContext context) {
    if (product == null) return;

    try {
      final cartController = Get.find<CartController>();

      if (product!.isSoldByWeight == true) {
        // Para produtos vendidos por peso, usar o peso como quantidade
        cartController.addItem(product!,
            quantity: (_weight.value * 10).round(), context: context);
        // Reset weight after adding to cart
        _weight.value = 0.5;
      } else {
        // Adicionar todos os itens de uma vez para evitar múltiplas notificações
        cartController.addItem(product!,
            quantity: _quantity.value, context: context);
        // Reset quantity after adding to cart
        _quantity.value = 1;
      }

      // Voltar para a tela de produtos após adicionar ao carrinho
      Get.back();
    } catch (e) {
      SnackBarUtils.showError(
        context,
        'Não foi possível adicionar o produto ao carrinho',
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

  double get totalPrice => (product?.isSoldByWeight == true)
      ? (product?.pricePerKg ?? 0.0) * _weight.value
      : (product?.price ?? 0.0) * _quantity.value;

  bool get canAddToCart =>
      product != null &&
      (product!.isAvailable ?? false) &&
      ((product!.isSoldByWeight ?? false) ||
          ((product!.stock ?? 0) > 0 &&
              _quantity.value <= (product!.stock ?? 0)));
}
