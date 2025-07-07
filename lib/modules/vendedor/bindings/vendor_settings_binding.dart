import 'package:get/get.dart';
import '../controllers/vendor_settings_controller.dart';

class VendorSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorSettingsController>(() => VendorSettingsController());
  }
}
