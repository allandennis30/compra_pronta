import 'package:get/get.dart';
import '../controllers/vendor_settings_controller.dart';

class VendedorSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendedorSettingsController>(() => VendedorSettingsController());
  }
}
