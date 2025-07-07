import 'package:get/get.dart';
import '../controllers/vendor_product_list_controller.dart';
import '../repositories/vendedor_product_repository.dart';

class VendorProductListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendedorProductRepository>(
      () => VendedorProductRepositoryImpl(),
    );

    Get.lazyPut<VendorProductListController>(
      () => VendorProductListController(
        repository: Get.find<VendedorProductRepository>(),
      ),
    );
  }
}
