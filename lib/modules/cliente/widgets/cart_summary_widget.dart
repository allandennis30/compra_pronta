import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../core/constants/app_constants.dart';

class CartSummaryWidget extends GetView<CartController> {
  final bool isDesktop;

  const CartSummaryWidget({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
          _title,
          const SizedBox(height: 16),
          _subtotalRow,
          const SizedBox(height: 8),
          _shippingRow,
          const Divider(height: 24),
          _totalRow,
          const SizedBox(height: 16),
          _checkoutButton,
          _minOrderMessage,
        ],
      ),
    );
  }

  Widget get _title => Text(
        'Resumo do Pedido',
        style: TextStyle(
          fontSize: isDesktop ? 18 : 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF424242),
        ),
      );

  Widget get _subtotalRow => Obx(() => _buildSummaryRow(
        'Subtotal:',
        'R\$ ${controller.subtotal.value.toStringAsFixed(2)}',
      ));

  Widget get _shippingRow => Obx(() => _buildSummaryRow(
        'Frete:',
        'R\$ ${controller.shipping.value.toStringAsFixed(2)}',
      ));

  Widget get _totalRow => Obx(() => _buildSummaryRow(
        'Total:',
        'R\$ ${controller.total.value.toStringAsFixed(2)}',
        isTotal: true,
      ));

  Widget get _checkoutButton => SizedBox(
        width: double.infinity,
        child: Obx(() => ElevatedButton(
              onPressed: controller.canCheckout()
                  ? () => Get.toNamed('/cliente/checkout')
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(AppConstants.successColor),
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

  Widget get _minOrderMessage => Obx(() => !controller.canCheckout()
      ? Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Valor mínimo: R\$ ${AppConstants.minOrderValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
            ),
            textAlign: TextAlign.center,
          ),
        )
      : const SizedBox());

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF424242),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? const Color(AppConstants.successColor)
                : const Color(0xFF424242),
          ),
        ),
      ],
    );
  }
}
