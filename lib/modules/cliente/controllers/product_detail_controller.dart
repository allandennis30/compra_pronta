import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import 'cart_controller.dart';
import 'cliente_main_controller.dart';
import '../../../core/utils/snackbar_utils.dart';

class ProductDetailController extends GetxController {
  final Rx<ProductModel?> _product = Rx<ProductModel?>(null);
  final RxInt _quantity = 1.obs;
  final RxDouble _weight = 0.5.obs; // Peso inicial de 0.5kg
  final RxBool _isLoading = false.obs;
  final RxBool _isFavorite = false.obs;
  bool _isSyncingFromCart = false; // Flag para evitar loops infinitos
  Timer? _debounceTimer; // Timer para debounce das atualizações

  ProductModel? get product => _product.value;
  int get quantity => _quantity.value;
  double get weight => _weight.value;
  bool get isLoading => _isLoading.value;
  bool get isFavorite => _isFavorite.value;

  @override
  void onInit() {
    super.onInit();
    _loadProductFromArguments();
    _setupQuantityListeners();
  }

  @override
  void onClose() {
    // Cancelar timer para evitar vazamentos de memória
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _loadProductFromArguments() {
    final arguments = Get.arguments;
    if (arguments is ProductModel) {
      _product.value = arguments;
      _checkIfFavorite();
      _syncQuantityFromCart();
    }
  }

  void _checkIfFavorite() {
    // TODO: Implementar verificação se produto está nos favoritos
    // Por enquanto, valor padrão é false
    _isFavorite.value = false;
  }

  void _syncQuantityFromCart() {
    if (product == null) return;
    
    _isSyncingFromCart = true; // Marcar que estamos sincronizando do carrinho
    
    try {
      // Verificar se o CartController está disponível
      if (!Get.isRegistered<CartController>()) {
        return;
      }
      
      final cartController = Get.find<CartController>();
      final cartItemIndex = cartController.items.indexWhere(
        (item) => item.product.id == product!.id,
      );
      
      if (cartItemIndex >= 0) {
        final cartItem = cartController.items[cartItemIndex];
        if (product!.isSoldByWeight == true) {
          // Para produtos vendidos por peso, converter quantidade para peso
          _weight.value = cartItem.displayQuantity;
        } else {
          // Para produtos normais, usar a quantidade diretamente
          _quantity.value = cartItem.quantity;
        }
      }
    } catch (e) {
      // Se não conseguir encontrar o CartController, usar valores padrão
      print('Erro ao sincronizar quantidade do carrinho: $e');
    } finally {
      _isSyncingFromCart = false; // Desmarcar a flag
    }
  }

  void _setupQuantityListeners() {
    // Listener para quantidade de produtos normais
    _quantity.listen((newQuantity) {
      _debounceUpdate();
    });
    
    // Listener para peso de produtos vendidos por peso
    _weight.listen((newWeight) {
      _debounceUpdate();
    });
  }

  void _debounceUpdate() {
    // Cancelar timer anterior se existir
    _debounceTimer?.cancel();
    
    // Criar novo timer com delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isSyncingFromCart) {
        _updateCartQuantity();
      }
    });
  }

  void _updateCartQuantity() {
    if (product == null || _isSyncingFromCart) return; // Não atualizar se estamos sincronizando do carrinho
    
    try {
      // Verificar se o CartController está disponível
      if (!Get.isRegistered<CartController>()) {
        return;
      }
      
      final cartController = Get.find<CartController>();
      final isAlreadyInCart = cartController.isProductInCart(product!.id ?? '');
      
      if (isAlreadyInCart) {
        if (product!.isSoldByWeight == true) {
          // Para produtos vendidos por peso, converter peso para quantidade
          cartController.updateQuantity(product!.id ?? '', (_weight.value * 10).round());
        } else {
          // Para produtos normais, usar a quantidade diretamente
          cartController.updateQuantity(product!.id ?? '', _quantity.value);
        }
      }
    } catch (e) {
      // Se não conseguir encontrar o CartController, ignorar
      print('Erro ao atualizar quantidade do carrinho: $e');
    }
  }

  int getCartQuantity() {
    if (product == null) return 0;
    
    try {
      final cartController = Get.find<CartController>();
      final cartItemIndex = cartController.items.indexWhere(
        (item) => item.product.id == product!.id,
      );
      
      if (cartItemIndex >= 0) {
        return cartController.items[cartItemIndex].quantity;
      }
      return 0;
    } catch (e) {
      return 0;
    }
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
      final isAlreadyInCart = cartController.isProductInCart(product!.id ?? '');

      if (product!.isSoldByWeight == true) {
        // Para produtos vendidos por peso, usar o peso como quantidade
        if (isAlreadyInCart) {
          // Se já está no carrinho, atualizar a quantidade
          cartController.updateQuantity(product!.id ?? '', (_weight.value * 10).round());
        } else {
          // Se não está no carrinho, adicionar
          cartController.addItem(product!,
              quantity: (_weight.value * 10).round(), context: context);
        }
      } else {
        // Para produtos normais
        if (isAlreadyInCart) {
          // Se já está no carrinho, atualizar a quantidade
          cartController.updateQuantity(product!.id ?? '', _quantity.value);
        } else {
          // Se não está no carrinho, adicionar
          cartController.addItem(product!,
              quantity: _quantity.value, context: context);
        }
      }

      // Voltar para a tela anterior após adicionar/atualizar no carrinho
      Get.back();
    } catch (e) {
      SnackBarUtils.showError(
        context,
        'Não foi possível adicionar o produto ao carrinho',
      );
    }
  }

  void goToCart() {
    // Navega de volta para a página principal do cliente
    Get.offAllNamed('/cliente');
    // Aguarda um momento para garantir que a página foi carregada
    Future.delayed(const Duration(milliseconds: 100), () {
      // Define a aba do carrinho como ativa
      try {
        final clienteMainController = Get.find<ClienteMainController>();
        clienteMainController.goToCart();
      } catch (e) {
        // Se não conseguir encontrar o controller, apenas navega
        print('Erro ao definir aba do carrinho: $e');
      }
    });
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

  bool get isInCart {
    if (product == null) return false;
    try {
      final cartController = Get.find<CartController>();
      return cartController.isProductInCart(product!.id ?? '');
    } catch (e) {
      return false;
    }
  }
}
