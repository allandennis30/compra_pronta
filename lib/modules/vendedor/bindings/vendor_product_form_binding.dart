import 'package:get/get.dart';
import '../controllers/vendor_product_form_controller.dart';
import '../repositories/vendedor_product_repository.dart';

class VendorProductFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendedorProductRepository>(
      () => VendedorProductRepositoryImpl(),
    );

    Get.lazyPut<VendorProductFormController>(
      () => VendorProductFormController(
        repository: Get.find<VendedorProductRepository>(),
      ),
    );
  }
}
