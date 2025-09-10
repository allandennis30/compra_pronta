import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/entregador_main_controller.dart';

class EntregadorMainPage extends StatelessWidget {
  const EntregadorMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Garante que o controller esteja disponível
    if (!Get.isRegistered<EntregadorMainController>()) {
      Get.put(EntregadorMainController());
    }

    final controller = Get.find<EntregadorMainController>();

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
      const Center(child: Text('Lista de Entregas')),
      const Center(child: Text('Mapa de Entregas')),
      const Center(child: Text('Histórico de Entregas')),
      const Center(child: Text('Perfil do Entregador')),
    ];

    return Scaffold(
      body: Column(
        children: [
          // Conteúdo principal
          Expanded(
            child: Obx(() => IndexedStack(
                  index: controller.currentIndex.value,
                  children: pages,
                )),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.setCurrentIndex,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.delivery_dining),
                label: 'Entregas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Mapa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Histórico',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          )),
    );
  }
}