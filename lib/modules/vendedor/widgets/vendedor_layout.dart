import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';

class VendedorLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const VendedorLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: VendedorBottomNav(currentIndex: currentIndex),
    );
  }
}

class VendedorBottomNav extends StatelessWidget {
  final int currentIndex;

  const VendedorBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => _navigateToPage(0),
              ),
              _buildNavItem(
                context,
                icon: Icons.inventory_2_outlined,
                label: 'Produtos',
                isActive: currentIndex == 1,
                onTap: () => _navigateToPage(1),
              ),
              _buildNavItem(
                context,
                icon: Icons.shopping_bag_outlined,
                label: 'Pedidos',
                isActive: currentIndex == 2,
                onTap: () => _navigateToPage(2),
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                label: 'Config',
                isActive: currentIndex == 3,
                onTap: () => _navigateToPage(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    // Só navega se não estiver na página atual
    if (index != currentIndex) {
      switch (index) {
        case 0:
          Get.offAllNamed('/vendor/dashboard');
          break;
        case 1:
          Get.offAllNamed('/vendor/produtos');
          break;
        case 2:
          Get.offAllNamed('/vendor/pedidos');
          break;
        case 3:
          Get.offAllNamed('/vendor/config');
          break;
      }
    }
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isActive ? primaryColor : AppColors.bottomNavUnselected(context),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? primaryColor : AppColors.bottomNavUnselected(context),
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
