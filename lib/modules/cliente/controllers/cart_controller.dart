import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../models/product_model.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../repositories/store_settings_repository.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => (product.isSoldByWeight ?? false)
      ? (product.pricePerKg ?? 0.0) *
          (quantity / 10.0) // Para produtos por peso, quantity é peso * 10
      : (product.price ?? 0.0) * quantity;

  double get displayQuantity => (product.isSoldByWeight ?? false)
      ? quantity / 10.0 // Converte de volta para kg
      : quantity.toDouble();

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: ProductModel.fromJson(json['product']),
        quantity: json['quantity'] ?? 1,
      );
}

class CartController extends GetxController {
  final _storage = GetStorage();
  final StoreSettingsRepository _storeSettingsRepository =
      StoreSettingsRepository();
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shipping = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxDouble vendorTaxaEntrega = 0.0.obs;
  final RxDouble vendorLimiteEntregaGratis = 0.0.obs;
  final RxDouble vendorPedidoMinimo = 0.0.obs;
  final RxBool isStoreOpen = true.obs;
  final RxString storeOpenMessage = ''.obs;
  DateTime? _lastSnackbarTime;

  List<CartItem> get items => cartItems;
  bool get isEmpty => cartItems.isEmpty;

  double get deliveryFee {
    return shipping.value;
  }

  double get currentMinOrderValue {
    final double value = vendorPedidoMinimo.value;
    // Não usar valor fixo global quando não houver política do vendedor
    return value > 0 ? value : 0.0;
  }

  int get itemCount {
    return cartItems.fold(0, (sum, item) {
      if (item.product.isSoldByWeight ?? false) {
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
    _applyVendorPolicy();
  }

  void _calculateTotals() {
    subtotal.value = cartItems.fold(0, (sum, item) => sum + item.total);
    shipping.value = AppConstants.baseDeliveryFee;
    total.value = subtotal.value + shipping.value;
    AppLogger.debug('[Totals] subtotal='
        '${subtotal.value.toStringAsFixed(2)} shipping='
        '${shipping.value.toStringAsFixed(2)} total=${total.value.toStringAsFixed(2)}');
  }

  Future<void> _applyVendorPolicy() async {
    try {
      if (cartItems.isEmpty) {
        vendorTaxaEntrega.value = 0.0;
        vendorLimiteEntregaGratis.value = 0.0;
        isStoreOpen.value = true;
        storeOpenMessage.value = '';
        _calculateTotals();
        return;
      }

      final firstProduct = cartItems.first.product;
      final sellerId = firstProduct.sellerId;
      AppLogger.debug('[Policy] sellerId='
          '$sellerId subtotal=${subtotal.value.toStringAsFixed(2)}');
      if (sellerId == null || sellerId.isEmpty) {
        _calculateTotals();
        return;
      }

      final policy = await _storeSettingsRepository.getStorePolicy(sellerId);
      if (policy != null) {
        try {
          AppLogger.info('[Policy] received=' +
              const JsonEncoder.withIndent('  ').convert(policy));
        } catch (_) {
          AppLogger.info('[Policy] received(simple)=' + policy.toString());
        }
        vendorTaxaEntrega.value = (policy['taxaEntrega'] ?? 0.0).toDouble();
        vendorLimiteEntregaGratis.value =
            (policy['limiteEntregaGratis'] ?? 0.0).toDouble();
        vendorPedidoMinimo.value =
            (policy['pedidoMinimo'] ?? policy['pedido_minimo'] ?? 0.0)
                .toDouble();
        AppLogger.debug('[Policy] taxaEntrega=${vendorTaxaEntrega.value} '
            'limiteGratis=${vendorLimiteEntregaGratis.value} '
            'pedidoMinimo=${vendorPedidoMinimo.value}');

        final bool lojaOffline = policy['lojaOffline'] == true;
        final bool aceitaForaHorario = policy['aceitaForaHorario'] == true;
        final String horarioInicio = policy['horarioInicio']?.toString() ?? '';
        final String horarioFim = policy['horarioFim']?.toString() ?? '';

        if (lojaOffline) {
          isStoreOpen.value = false;
          storeOpenMessage.value =
              'Loja temporariamente offline. O pedido será processado no próximo dia de funcionamento.';
        } else if (horarioInicio.isNotEmpty && horarioFim.isNotEmpty) {
          try {
            final now = DateTime.now();
            final sp = horarioInicio.split(':');
            final ep = horarioFim.split(':');
            final start = DateTime(now.year, now.month, now.day,
                int.parse(sp[0]), int.parse(sp[1]));
            final end = DateTime(now.year, now.month, now.day, int.parse(ep[0]),
                int.parse(ep[1]));
            final open = now.isAfter(start) && now.isBefore(end);
            if (open || aceitaForaHorario) {
              isStoreOpen.value = true;
              storeOpenMessage.value = '';
            } else {
              isStoreOpen.value = false;
              storeOpenMessage.value =
                  'Fora do horário de funcionamento. Seu pedido será entregue no próximo dia útil da loja.';
            }
            AppLogger.debug('[Policy] open=$open aceitaForaHorario='
                '$aceitaForaHorario isStoreOpen=${isStoreOpen.value}');
          } catch (_) {
            isStoreOpen.value = true;
            storeOpenMessage.value = '';
          }
        } else {
          isStoreOpen.value = true;
          storeOpenMessage.value = '';
        }

        final applied = subtotal.value >= vendorLimiteEntregaGratis.value
            ? 0.0
            : vendorTaxaEntrega.value;
        shipping.value = applied;
        total.value = subtotal.value + shipping.value;
        AppLogger.debug('[TotalsAfterPolicy] shipping='
            '${shipping.value.toStringAsFixed(2)} total='
            '${total.value.toStringAsFixed(2)} currentMin='
            '${currentMinOrderValue.toStringAsFixed(2)} canCheckout='
            '${canCheckout()}');
      } else {
        _calculateTotals();
      }
    } catch (e) {
      AppLogger.warning('⚠️ Falha ao obter política de entrega: $e');
      _calculateTotals();
    }
  }

  void _loadCart() {
    try {
      final cartData = _storage.read(AppConstants.cartKey);
      if (cartData != null && cartData is List) {
        cartItems.clear();
        for (var itemData in cartData) {
          if (itemData is Map<String, dynamic>) {
            try {
              final cartItem = CartItem.fromJson(itemData);
              cartItems.add(cartItem);
            } catch (e) {
              AppLogger.error('Erro ao carregar item do carrinho', e);
            }
          }
        }
        AppLogger.info('Carrinho carregado com ${cartItems.length} itens');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar carrinho', e);
    }
  }

  void _saveCart() {
    try {
      final cartData = cartItems.map((item) => item.toJson()).toList();
      _storage.write(AppConstants.cartKey, cartData);
      AppLogger.info('Carrinho salvo com ${cartItems.length} itens');
    } catch (e) {
      AppLogger.error('Erro ao salvar carrinho', e);
    }
  }

  void addItem(ProductModel product,
      {int quantity = 1, BuildContext? context}) {
    final existingIndex =
        cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
    } else {
      cartItems.add(CartItem(product: product, quantity: quantity));
    }

    _calculateTotals();
    _applyVendorPolicy();
    _saveCart();
    AppLogger.info('[Cart] addItem id=${product.id} qty=$quantity subtotal='
        '${subtotal.value.toStringAsFixed(2)} currentMin='
        '${currentMinOrderValue.toStringAsFixed(2)} canCheckout=${canCheckout()}');

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
    _applyVendorPolicy();
    _saveCart();
    AppLogger.info('[Cart] removeItem id=$productId subtotal='
        '${subtotal.value.toStringAsFixed(2)} currentMin='
        '${currentMinOrderValue.toStringAsFixed(2)} canCheckout=${canCheckout()}');
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
      _applyVendorPolicy();
      _saveCart();
      AppLogger.info('[Cart] updateQuantity id=$productId qty=$quantity '
          'subtotal=${subtotal.value.toStringAsFixed(2)} currentMin='
          '${currentMinOrderValue.toStringAsFixed(2)} canCheckout=${canCheckout()}');
      // Não mostrar snackbar aqui - feedback visual sutil é suficiente
    }
  }

  void clearCart() {
    cartItems.clear();
    _calculateTotals();
    _applyVendorPolicy();
    _saveCart();
  }

  bool canCheckout() {
    return !isEmpty && subtotal.value >= currentMinOrderValue;
  }

  bool isProductInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
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
