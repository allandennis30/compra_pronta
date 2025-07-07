import 'package:get/get.dart';
import '../../modules/cliente/controllers/product_list_controller.dart';
import '../../modules/cliente/controllers/checkout_controller.dart';
import '../../modules/cliente/controllers/order_history_controller.dart';
import '../../modules/cliente/repositories/product_repository.dart';
import '../../modules/cliente/repositories/cart_repository.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../repositories/repository_factory.dart';

class ClienteBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories usando factory
    Get.lazyPut<AuthRepository>(() => RepositoryFactory.createAuthRepository());
    Get.lazyPut<ProductRepository>(
        () => RepositoryFactory.createProductRepository());
    Get.lazyPut<CartRepository>(() => RepositoryFactory.createCartRepository());

    // Controllers
    Get.lazyPut<ProductListController>(() => ProductListController());
    Get.lazyPut<CheckoutController>(() => CheckoutController());
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
  }
}
