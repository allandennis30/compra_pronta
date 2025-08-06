// TODO: Este arquivo faz parte de uma refatoração em andamento
// onde todos os nomes "vendor" devem ser alterados para "vendedor"
// Os seguintes passos precisam ser completados:
// 1. Renomear os arquivos de controllers/repositories de vendor_* para vendedor_*
// 2. Atualizar as importações em todos os arquivos
// 3. Atualizar as referências de classe nos bindings

import 'package:get/get.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/vendedor/controllers/vendor_product_list_controller.dart';
import '../../modules/vendedor/controllers/vendor_product_form_controller.dart';
import '../../modules/vendedor/controllers/vendor_order_list_controller.dart';
import '../../modules/vendedor/controllers/vendor_order_detail_controller.dart';
import '../../modules/vendedor/controllers/vendor_scan_controller.dart';
import '../../modules/vendedor/controllers/vendor_metrics_controller.dart';
import '../../modules/vendedor/repositories/vendor_metrics_repository.dart';
import '../../modules/vendedor/repositories/vendedor_product_repository.dart';
import '../repositories/repository_factory.dart';

class VendedorBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories usando factory
    Get.lazyPut<AuthRepository>(() => RepositoryFactory.createAuthRepository());
    // TODO: Renomear para VendedorMetricsRepository após renomear os arquivos
    Get.lazyPut<VendorMetricsRepository>(
        () => RepositoryFactory.createVendorMetricsRepository());
    Get.lazyPut<VendedorProductRepository>(
        () => RepositoryFactory.createVendedorProductRepository());

    // Controllers
    // TODO: Renomear para VendedorProductListController após renomear os arquivos
    Get.lazyPut<VendorProductListController>(
        () => VendorProductListController(repository: Get.find()));
    // TODO: Renomear para VendedorProductFormController após renomear os arquivos
    Get.lazyPut<VendorProductFormController>(
        () => VendorProductFormController(repository: Get.find()));
    // TODO: Renomear para VendedorOrderListController após renomear os arquivos
    Get.lazyPut<VendorOrderListController>(() => VendorOrderListController());
    // TODO: Renomear para VendedorOrderDetailController após renomear os arquivos
    Get.lazyPut<VendorOrderDetailController>(
        () => VendorOrderDetailController());
    // TODO: Renomear para VendedorScanController após renomear os arquivos
    Get.lazyPut<VendorScanController>(() => VendorScanController());
    // TODO: Renomear para VendedorMetricsController após renomear os arquivos
    Get.lazyPut<VendorMetricsController>(() => VendorMetricsController());
  }
}
