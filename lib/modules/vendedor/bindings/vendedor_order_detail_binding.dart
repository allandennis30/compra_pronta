import 'package:get/get.dart';
import '../controllers/vendedor_order_detail_controller.dart';
import '../controllers/vendor_order_detail_controller.dart';
import '../../../core/services/api_service.dart';
import '../repositories/vendor_order_repository.dart';
import '../../../modules/auth/controllers/auth_controller.dart';

class VendedorOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<ApiService>(() => ApiService());

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController());

    // Repositories
    Get.lazyPut<VendorOrderRepository>(() => VendorOrderRepositoryImpl());

    // Controllers
    Get.lazyPut<VendedorOrderDetailController>(
        () => VendedorOrderDetailController());
    // Alias para compatibilidade
    Get.lazyPut<VendorOrderDetailController>(
        () => VendorOrderDetailController());
  }
}
