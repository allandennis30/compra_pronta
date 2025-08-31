import 'package:get/get.dart';
import '../controllers/vendor_product_form_controller.dart';
import '../repositories/vendedor_product_repository.dart';
import '../../../core/repositories/repository_factory.dart';

class VendedorProductFormBinding extends Bindings {
  @override
  void dependencies() {
    // Verificar se já existe uma instância antes de criar
    if (!Get.isRegistered<VendedorProductRepository>()) {
      Get.put<VendedorProductRepository>(
        RepositoryFactory.createVendedorProductRepository(),
        permanent: false,
      );
    }

    if (!Get.isRegistered<VendorProductFormController>()) {
      Get.put<VendorProductFormController>(
        VendorProductFormController(
          repository: Get.find<VendedorProductRepository>(),
        ),
        permanent: false,
      );
    }
  }
}
