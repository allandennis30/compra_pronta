import 'package:get/get.dart';
import '../../modules/cliente/controllers/product_list_controller.dart';
import '../../modules/cliente/controllers/cart_controller.dart';
import '../../modules/cliente/controllers/order_history_controller.dart';
import '../../modules/cliente/controllers/delivery_controller.dart';
import '../services/api_service.dart';
import '../../modules/cliente/controllers/profile_controller.dart';
import '../../modules/cliente/repositories/product_repository.dart';
import '../../modules/cliente/repositories/cart_repository.dart';
import '../../modules/cliente/repositories/order_repository.dart';
import '../../modules/cliente/repositories/delivery_repository.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../repositories/repository_factory.dart';

class ClienteBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories usando factory (apenas se não existirem globalmente)
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => RepositoryFactory.createAuthRepository());
    }
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
          () => RepositoryFactory.createProductRepository());
    }
    if (!Get.isRegistered<CartRepository>()) {
      Get.lazyPut<CartRepository>(() => RepositoryFactory.createCartRepository());
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(
          () => RepositoryFactory.createOrderRepository());
    }
    Get.lazyPut<DeliveryRepository>(() => DeliveryRepository());

    // Services
    Get.lazyPut<ApiService>(() => ApiService());

    // Controllers
    Get.lazyPut<ProductListController>(() => ProductListController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    if (!Get.isRegistered<DeliveryController>()) {
      Get.lazyPut<DeliveryController>(() => DeliveryController());
    }
  }
}
