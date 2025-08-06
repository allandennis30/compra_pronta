import 'package:get/get.dart';
import '../controllers/vendor_order_list_controller.dart';

class VendorOrderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorOrderListController>(
      () => VendorOrderListController(),
    );
  }
}