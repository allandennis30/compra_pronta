import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';
import '../controllers/cart_controller.dart';
import '../../../core/services/api_service.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => CheckoutController());
  }
}
