import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/client_bottom_nav.dart';
import '../controllers/cliente_main_controller.dart';
import '../controllers/delivery_controller.dart';
import 'product_list_page.dart';
import 'cart_page.dart';
import 'order_history_page.dart';
import 'profile_page.dart';

class ClienteMainPage extends StatelessWidget {
  const ClienteMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Garante que o controller esteja disponível
    if (!Get.isRegistered<ClienteMainController>()) {
      Get.put(ClienteMainController());
    }

    // Garante que o DeliveryController esteja disponível
    if (!Get.isRegistered<DeliveryController>()) {
      Get.put(DeliveryController());
    }

    final controller = Get.find<ClienteMainController>();

    // Se vier argumento de índice inicial, aplica ao controller
    final args = Get.arguments;
    final initialIndex = (args is Map && args['initialIndex'] is int)
        ? args['initialIndex'] as int
        : null;
    if (initialIndex != null) {
      controller.setCurrentIndex(initialIndex);
    }

    // Lista de páginas que serão exibidas
    final List<Widget> pages = [
      const ProductListPage(),
      const CartPage(),
      const OrderHistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Column(
        children: [
          // Switch de modo de entrega
          // Conteúdo principal
          Expanded(
            child: Obx(() => IndexedStack(
                  index: controller.currentIndex.value,
                  children: pages,
                )),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => ClientBottomNav(
            currentIndex: controller.currentIndex.value,
            onTabTapped: controller.setCurrentIndex,
          )),
    );
  }
}
