import 'package:get/get.dart';
import '../controllers/entregador_main_controller.dart';
import '../controllers/delivery_list_controller.dart';
import '../controllers/delivery_detail_controller.dart';
import '../repositories/entregador_repository.dart';

class EntregadorBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<EntregadorRepository>(() => EntregadorRepository());
    
    // Controllers
    Get.lazyPut<EntregadorMainController>(() => EntregadorMainController());
    Get.lazyPut<DeliveryListController>(() => DeliveryListController());
    Get.lazyPut<DeliveryDetailController>(() => DeliveryDetailController());
  }
}