import 'package:get/get.dart';
import '../../modules/vendedor/controllers/vendor_product_list_controller.dart';
import '../../modules/vendedor/controllers/vendor_product_form_controller.dart';
import '../../modules/vendedor/controllers/vendor_order_list_controller.dart';
import '../../modules/vendedor/controllers/vendor_order_detail_controller.dart';
import '../../modules/vendedor/controllers/vendor_scan_controller.dart';
import '../../modules/vendedor/controllers/vendor_metrics_controller.dart';
import '../../modules/vendedor/repositories/vendor_metrics_repository.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../repositories/repository_factory.dart';

class VendedorBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories usando factory
    Get.lazyPut<AuthRepository>(() => RepositoryFactory.createAuthRepository());
    Get.lazyPut<VendorMetricsRepository>(() => RepositoryFactory.createVendorMetricsRepository());
    
    // Controllers
    Get.lazyPut<VendorProductListController>(() => VendorProductListController());
    Get.lazyPut<VendorProductFormController>(() => VendorProductFormController());
    Get.lazyPut<VendorOrderListController>(() => VendorOrderListController());
    Get.lazyPut<VendorOrderDetailController>(() => VendorOrderDetailController());
    Get.lazyPut<VendorScanController>(() => VendorScanController());
    Get.lazyPut<VendorMetricsController>(() => VendorMetricsController());
  }
} 