import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/product_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.isSoldByWeight 
      ? (product.pricePerKg ?? 0.0) * (quantity / 10.0) // Para produtos por peso, quantity é peso * 10
      : product.price * quantity;

  double get displayQuantity => product.isSoldByWeight 
      ? quantity / 10.0 // Converte de volta para kg
      : quantity.toDouble();
}

class CartController extends GetxController {
  final _storage = GetStorage();
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shipping = 0.0.obs;
  final RxDouble total = 0.0.obs;
  DateTime? _lastSnackbarTime;

  List<CartItem> get items => cartItems;
  bool get isEmpty => cartItems.isEmpty;

  double get deliveryFee {
    return shipping.value;
  }

  int get itemCount {
    return cartItems.fold(0, (sum, item) {
      if (item.product.isSoldByWeight) {
        // Para produtos por peso, conta como 1 item independente do peso
        return sum + 1;
      } else {
        return sum + item.quantity;
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    _loadCart();
    _calculateTotals();
  }

  void _calculateTotals() {
    subtotal.value = cartItems.fold(0, (sum, item) => sum + item.total);
    shipping.value = AppConstants.baseDeliveryFee;
    total.value = subtotal.value + shipping.value;
  }

  void _loadCart() {
    try {
      final cartData = _storage.read(AppConstants.cartKey);
      if (cartData != null) {
        // TODO: Implementar carregamento do carrinho do storage
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar carrinho', e);
    }
  }

  void _saveCart() {
    try {
      // TODO: Implementar salvamento do carrinho no storage
    } catch (e) {
      AppLogger.error('Erro ao salvar carrinho', e);
    }
  }

  void addItem(ProductModel product, {int quantity = 1, BuildContext? context}) {
    final existingIndex =
        cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
    } else {
      cartItems.add(CartItem(product: product, quantity: quantity));
    }

    _calculateTotals();
    _saveCart();
    
    // Evitar múltiplas chamadas de snackbar em sequência rápida
    final now = DateTime.now();
    if (_lastSnackbarTime == null || 
        now.difference(_lastSnackbarTime!).inMilliseconds > 1000) {
      _lastSnackbarTime = now;
      if (context != null) {
        SnackBarUtils.showSuccess(context, 'Produto adicionado ao carrinho!');
      }
    }
  }

  void removeItem(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
    _calculateTotals();
    _saveCart();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      cartItems[index].quantity = quantity;
      cartItems.refresh(); // Force refresh the observable list
      _calculateTotals();
      _saveCart();
      // Não mostrar snackbar aqui - feedback visual sutil é suficiente
    }
  }

  void clearCart() {
    cartItems.clear();
    _calculateTotals();
    _saveCart();
  }

  bool canCheckout() {
    return !isEmpty && subtotal.value >= AppConstants.minOrderValue;
  }

  void showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Carrinho'),
        content: const Text('Tem certeza que deseja limpar o carrinho?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              clearCart();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppConstants.errorColor),
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
