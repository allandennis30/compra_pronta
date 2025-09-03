import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../core/widgets/themed_bottom_nav.dart';

/// Versão temática da navbar do cliente usando o sistema de cores reativas
class ClientBottomNavThemed extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTabTapped;

  const ClientBottomNavThemed({
    super.key,
    this.currentIndex = 0,
    this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final itemCount = cartController.itemCount;

      final items = <ThemedBottomNavItemWithBadge>[
        ThemedBottomNavItemWithBadge(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Início',
        ),
        ThemedBottomNavItemWithBadge(
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: 'Carrinho',
          badgeCount: itemCount,
        ),
        ThemedBottomNavItemWithBadge(
          icon: Icons.history_outlined,
          activeIcon: Icons.history,
          label: 'Histórico',
        ),
        ThemedBottomNavItemWithBadge(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Perfil',
        ),
      ];

      return ThemedBottomNavWithBadge(
        currentIndex: currentIndex,
        items: items,
        onTap: _handleTabTap,
      );
    });
  }

  void _handleTabTap(int index) {
    if (onTabTapped != null) {
      // Se temos um callback local, use-o (navegação com IndexedStack)
      onTabTapped!(index);
    } else {
      // Fallback para navegação tradicional (para compatibilidade)
      switch (index) {
        case 0:
          Get.offAllNamed('/cliente/produtos');
          break;
        case 1:
          Get.toNamed('/cliente/carrinho');
          break;
        case 2:
          Get.toNamed('/cliente/historico');
          break;
        case 3:
          Get.toNamed('/cliente/perfil');
          break;
      }
    }
  }
}
