import 'package:get/get.dart';
import '../controllers/vendor_order_list_controller.dart';

class VendedorOrderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorOrderListController>(
      () => VendorOrderListController(),
    );
  }
}
