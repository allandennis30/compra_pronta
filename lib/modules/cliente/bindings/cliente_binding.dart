import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../controllers/cliente_main_controller.dart';

class ClienteBinding extends Bindings {
  @override
  void dependencies() {
    // Garante que o controller seja criado imediatamente
    if (!Get.isRegistered<ClienteMainController>()) {
      Get.put<ClienteMainController>(ClienteMainController());
    }
    // ProfileController será gerenciado pelo GetBuilder
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
