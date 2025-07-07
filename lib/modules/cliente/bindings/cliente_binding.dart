import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/profile_controller.dart';

class ClienteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
