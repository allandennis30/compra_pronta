import 'package:get/get.dart';
import '../../modules/cliente/controllers/cart_controller.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers globais que devem estar sempre disponíveis
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
