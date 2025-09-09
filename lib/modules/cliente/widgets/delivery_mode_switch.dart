import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/delivery_controller.dart';
import '../pages/delivery_main_page.dart';
import '../pages/cliente_main_page.dart';
import '../../auth/controllers/auth_controller.dart';

class DeliveryModeSwitch extends StatelessWidget {
  const DeliveryModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final DeliveryController deliveryController = Get.find<DeliveryController>();

    return Obx(() {
      // Só mostra o switch se o usuário for entregador
      if (!deliveryController.isDeliveryUser.value) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: Colors.orange[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo de Uso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alterne entre comprar e entregar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    'Cliente',
                    Icons.shopping_cart,
                    true, // isClientMode
                    () => _switchToClientMode(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeButton(
                    'Entregador',
                    Icons.delivery_dining,
                    false, // isClientMode
                    () => _switchToDeliveryMode(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildModeButton(
    String title,
    IconData icon,
    bool isClientMode,
    VoidCallback onTap,
  ) {
    final isCurrentRoute = isClientMode
        ? Get.currentRoute == '/cliente'
        : Get.currentRoute == '/delivery';

    return GestureDetector(
      onTap: isCurrentRoute ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: isCurrentRoute
              ? Colors.orange
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.orange,
            width: 1.5,
          ),
          boxShadow: isCurrentRoute
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isCurrentRoute
                  ? Colors.white
                  : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isCurrentRoute
                    ? Colors.white
                    : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _switchToClientMode() async {
    final authController = Get.find<AuthController>();
    await authController.saveUserMode('cliente');
    
    Get.offAll(
      () => const ClienteMainPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _switchToDeliveryMode() async {
    final authController = Get.find<AuthController>();
    await authController.saveUserMode('entregador');
    
    Get.offAll(
      () => const DeliveryMainPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }
}