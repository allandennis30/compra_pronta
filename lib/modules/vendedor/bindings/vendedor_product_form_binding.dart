import 'package:get/get.dart';
import '../controllers/vendor_product_form_controller.dart';
import '../repositories/vendedor_product_repository.dart';
import '../../../core/repositories/repository_factory.dart';
import '../../../repositories/vendor_category_repository.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/controllers/auth_controller.dart';

class VendedorProductFormBinding extends Bindings {
  @override
  void dependencies() {
    // Registrar AuthRepository se não existir
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(
        AuthRepositoryImpl(),
        permanent: true,
      );
    }

    // Registrar AuthController se não existir
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(),
        permanent: true,
      );
    }

    // Registrar VendorCategoryRepository
    if (!Get.isRegistered<VendorCategoryRepository>()) {
      Get.put<VendorCategoryRepository>(
        VendorCategoryRepository(Get.find<AuthRepository>()),
        permanent: false,
      );
    }

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
