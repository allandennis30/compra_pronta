import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../core/themes/app_colors.dart';

class CartSummaryWidget extends GetView<CartController> {
  final bool isDesktop;

  const CartSummaryWidget({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: isDesktop ? BorderRadius.circular(12) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _title(context),
          const SizedBox(height: 16),
          _subtotalRow(context),
          const SizedBox(height: 8),
          _shippingRow(context),
          const Divider(height: 24),
          _totalRow(context),
          const SizedBox(height: 16),
          _checkoutButton(context),
          _minOrderMessage(context),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) => Text(
        'Resumo do Pedido',
        style: TextStyle(
          fontSize: isDesktop ? 18 : 16,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface(context),
        ),
      );

  Widget _subtotalRow(BuildContext context) => Obx(() => _buildSummaryRow(
        context,
        'Subtotal:',
        'R\$ ${controller.subtotal.value.toStringAsFixed(2)}',
      ));

  Widget _shippingRow(BuildContext context) => Obx(() {
        final isShippingFree = controller.shipping.value == 0.0;
        final shippingColor = isShippingFree ? Colors.green : AppColors.onSurface(context);
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frete:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColors.onSurface(context),
                  ),
                ),
                Text(
                  isShippingFree ? 'GRÁTIS' : 'R\$ ${controller.shipping.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isShippingFree ? FontWeight.bold : FontWeight.normal,
                    color: shippingColor,
                  ),
                ),
              ],
            ),
            if (!isShippingFree && controller.vendorLimiteEntregaGratis.value > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Frete grátis a partir de R\$ ${controller.vendorLimiteEntregaGratis.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      });

  Widget _totalRow(BuildContext context) => Obx(() => _buildSummaryRow(
        context,
        'Total:',
        'R\$ ${controller.total.value.toStringAsFixed(2)}',
        isTotal: true,
      ));

  Widget _checkoutButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Obx(() => ElevatedButton(
              onPressed: controller.canCheckout()
                  ? () => Get.toNamed(Routes.clienteCheckout)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.success(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Finalizar Compra',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      );

  Widget _minOrderMessage(BuildContext context) => Obx(() {
        final minValue = controller.currentMinOrderValue;
        if (minValue <= 0 || controller.canCheckout()) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Pedido mínimo do vendedor: R\$ ${minValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant(context),
            ),
            textAlign: TextAlign.center,
          ),
        );
      });

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.onSurface(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? AppColors.success(context)
                : AppColors.onSurface(context),
          ),
        ),
      ],
    );
  }
}
