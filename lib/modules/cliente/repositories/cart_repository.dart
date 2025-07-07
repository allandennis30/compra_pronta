import 'package:get_storage/get_storage.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addItem(ProductModel product, {int quantity = 1});
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeItem(String productId);
  Future<void> clearCart();
  Future<void> saveCart(List<CartItem> items);
}

class CartRepositoryImpl implements CartRepository {
  final GetStorage _storage = GetStorage();

  String get _userCartKey {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser;
    return currentUser != null
        ? '${AppConstants.cartKey}_${currentUser.id}'
        : AppConstants.cartKey;
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    try {
      // Verificar se usuário está autenticado
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        AppLogger.error('Usuário não autenticado');
        return [];
      }

      final cartData = _storage.read(_userCartKey);
      if (cartData != null && cartData is List) {
        return cartData
            .map((item) => CartItem(
                  product: ProductModel.fromJson(item['product']),
                  quantity: item['quantity'],
                ))
            .toList();
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar carrinho', e);
    }
    return [];
  }

  @override
  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    try {
      final items = await getCartItems();
      final existingIndex =
          items.indexWhere((item) => item.product.id == product.id);

      if (existingIndex >= 0) {
        items[existingIndex].quantity += quantity;
      } else {
        items.add(CartItem(product: product, quantity: quantity));
      }

      await saveCart(items);
    } catch (e) {
      AppLogger.error('Erro ao adicionar item ao carrinho', e);
      rethrow;
    }
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final items = await getCartItems();

      if (quantity <= 0) {
        items.removeWhere((item) => item.product.id == productId);
      } else {
        final index = items.indexWhere((item) => item.product.id == productId);
        if (index >= 0) {
          items[index].quantity = quantity;
        }
      }

      await saveCart(items);
    } catch (e) {
      AppLogger.error('Erro ao atualizar quantidade', e);
      rethrow;
    }
  }

  @override
  Future<void> removeItem(String productId) async {
    try {
      final items = await getCartItems();
      items.removeWhere((item) => item.product.id == productId);
      await saveCart(items);
    } catch (e) {
      AppLogger.error('Erro ao remover item', e);
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _storage.remove(_userCartKey);
    } catch (e) {
      AppLogger.error('Erro ao limpar carrinho', e);
      rethrow;
    }
  }

  @override
  Future<void> saveCart(List<CartItem> items) async {
    try {
      final cartData = items
          .map((item) => {
                'product': item.product.toJson(),
                'quantity': item.quantity,
              })
          .toList();

      await _storage.write(_userCartKey, cartData);
    } catch (e) {
      AppLogger.error('Erro ao salvar carrinho', e);
      rethrow;
    }
  }
}
