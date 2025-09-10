import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/cliente/controllers/cart_controller.dart';
import '../../modules/cliente/controllers/product_list_controller.dart';
import '../../modules/cliente/controllers/delivery_controller.dart';
import '../../modules/cliente/repositories/product_repository.dart';
import '../../modules/cliente/repositories/order_repository.dart';
import '../../modules/cliente/repositories/cart_repository.dart';
import '../controllers/update_controller.dart';
import '../repositories/repository_factory.dart';
import 'app_update_service.dart';

class InitializeServices {
  static void init() {
    // Repositories globais usando factory
    Get.put<AuthRepository>(RepositoryFactory.createAuthRepository());
    Get.put<ProductRepository>(RepositoryFactory.createProductRepository());
    Get.put<OrderRepository>(RepositoryFactory.createOrderRepository());
    Get.put<CartRepository>(RepositoryFactory.createCartRepository());

    // Services globais
    Get.put(AppUpdateService());

    // Controllers globais
    Get.put(AuthController());
    Get.put(CartController());
    Get.put(UpdateController());
    Get.put(ProductListController());
    Get.put(DeliveryController());

    
  }
}