import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart';
import '../controllers/cart_controller.dart';
import '../repositories/cart_repository.dart';
import '../../../core/repositories/repository_factory.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure CartRepository is available
    if (!Get.isRegistered<CartRepository>()) {
      Get.lazyPut<CartRepository>(() => RepositoryFactory.createCartRepository());
    }
    
    // Ensure CartController is available
    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut<CartController>(() => CartController());
    }
    
    Get.lazyPut<ProductDetailController>(
      () => ProductDetailController(),
    );
  }
}