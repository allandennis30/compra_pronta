import 'package:get/get.dart';
import '../controllers/vendor_product_form_controller.dart';
import '../repositories/vendedor_product_repository.dart';
import '../../../core/repositories/repository_factory.dart';

class VendedorProductFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendedorProductRepository>(
      () => RepositoryFactory.createVendedorProductRepository(),
    );

    Get.lazyPut<VendorProductFormController>(
      () => VendorProductFormController(
        repository: Get.find<VendedorProductRepository>(),
      ),
    );
  }
}
