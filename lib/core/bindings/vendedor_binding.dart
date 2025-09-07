// TODO: Este arquivo faz parte de uma refatoração em andamento
// onde todos os nomes "vendor" devem ser alterados para "vendedor"
// Os seguintes passos precisam ser completados:
// 1. Renomear os arquivos de controllers/repositories de vendor_* para vendedor_*
// 2. Atualizar as importações em todos os arquivos
// 3. Atualizar as referências de classe nos bindings

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../modules/auth/repositories/auth_repository.dart';
import '../../modules/vendedor/controllers/vendor_product_list_controller.dart';
import '../../modules/vendedor/controllers/vendor_product_form_controller.dart';
import '../../modules/vendedor/controllers/vendor_order_list_controller.dart';
import '../../modules/vendedor/controllers/vendedor_order_detail_controller.dart';
import '../../modules/vendedor/controllers/vendor_scan_controller.dart';
import '../../modules/vendedor/controllers/vendor_metrics_controller.dart';
import '../../modules/vendedor/repositories/vendor_metrics_repository.dart';
import '../../modules/vendedor/repositories/vendedor_product_repository.dart';
import '../../modules/vendedor/repositories/vendor_order_repository.dart';
import '../repositories/repository_factory.dart';
import '../services/api_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import 'notification_binding.dart';

class VendedorBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<ApiService>(() => ApiService());
    
    // Inicializar serviços de notificação
    final notificationBinding = NotificationBinding();
    notificationBinding.dependencies();

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController());

    // Repositories usando factory
    Get.lazyPut<AuthRepository>(() => RepositoryFactory.createAuthRepository());
    // TODO: Renomear para VendedorMetricsRepository após renomear os arquivos
    Get.lazyPut<VendorMetricsRepository>(
        () => RepositoryFactory.createVendorMetricsRepository());
    Get.lazyPut<VendedorProductRepository>(
        () => RepositoryFactory.createVendedorProductRepository());
    Get.lazyPut<VendorOrderRepository>(() => VendorOrderRepositoryImpl());

    // Controllers
    // TODO: Renomear para VendedorProductListController após renomear os arquivos
    Get.lazyPut<VendedorProductListController>(
        () => VendedorProductListController(repository: Get.find()));
    // TODO: Renomear para VendedorProductFormController após renomear os arquivos
    Get.lazyPut<VendorProductFormController>(
        () => VendorProductFormController(repository: Get.find()));
    // TODO: Renomear para VendedorOrderListController após renomear os arquivos
    Get.lazyPut<VendorOrderListController>(() => VendorOrderListController());
    // TODO: Renomear para VendedorOrderDetailController após renomear os arquivos
    Get.lazyPut<VendedorOrderDetailController>(
        () => VendedorOrderDetailController());
    // TODO: Renomear para VendedorScanController após renomear os arquivos
    Get.lazyPut<VendorScanController>(() => VendorScanController());
    // TODO: Renomear para VendedorMetricsController após renomear os arquivos
    Get.lazyPut<VendorMetricsController>(() => VendorMetricsController());
    
    // Inicializar serviços de notificação após todas as dependências
    _initializeNotificationServices();
  }
  
  /// Inicializa os serviços de notificação de forma assíncrona
  void _initializeNotificationServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationBinding.initializeServices();
        await NotificationBinding.startOrderMonitoring();
        print('✅ Sistema de notificações ativado para vendedor');
      } catch (e) {
        print('❌ Erro ao inicializar notificações: $e');
      }
    });
  }
}
