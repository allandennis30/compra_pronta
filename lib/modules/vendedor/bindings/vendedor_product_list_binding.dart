import 'package:get/get.dart';
import '../controllers/vendor_product_list_controller.dart';
import '../repositories/vendedor_product_repository.dart';

class VendedorProductListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendedorProductRepository>(
      () => VendedorProductRepositoryImpl(),
    );

    Get.lazyPut<VendedorProductListController>(
      () => VendedorProductListController(
        repository: Get.find<VendedorProductRepository>(),
      ),
    );
  }
}
