import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/client_bottom_nav.dart';
import '../../../core/themes/app_colors.dart';

class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface(context))),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _body(context),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 1),
    );
  }

  Widget _body(BuildContext context) => Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _stepper(context),
            Expanded(child: _currentStepContent(context)),
          ],
        );
      });

  Widget _stepper(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStep(context, 0, 'Dados', Icons.person),
            _buildStepLine(context),
            _buildStep(context, 1, 'Pagamento', Icons.payment),
            _buildStepLine(context),
            _buildStep(context, 2, 'Revisão', Icons.check_circle),
          ],
        ),
      );

  Widget _buildStep(
      BuildContext context, int step, String title, IconData icon) {
    final isActive = controller.currentStep.value == step;
    final isCompleted = controller.currentStep.value > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success(context)
                  : isActive
                      ? AppColors.primary(context)
                      : AppColors.surfaceVariant(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted || isActive
                  ? Colors.white
                  : AppColors.onSurfaceVariant(context),
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? AppColors.primary(context)
                  : AppColors.onSurfaceVariant(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(BuildContext context) {
    return Container(
      height: 2,
      width: 20,
      color: controller.currentStep.value > 0
          ? AppColors.surfaceVariant(context)
          : AppColors.border(context),
    );
  }

  Widget _currentStepContent(BuildContext context) {
    switch (controller.currentStep.value) {
      case 0:
        return _personalDataStep(context);
      case 1:
        return _paymentStep(context);
      case 2:
        return _reviewStep(context);
      default:
        return const SizedBox();
    }
  }

  Widget _personalDataStep(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados Pessoais',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              context: context,
              label: 'Nome Completo',
              controller: controller.clientNameController,
              onChanged: (value) => controller.clientName.value = value,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Email',
              controller: controller.clientEmailController,
              onChanged: (value) => controller.clientEmail.value = value,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Telefone',
              controller: controller.clientPhoneController,
              onChanged: (value) => controller.clientPhone.value = value,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Endereço de Entrega',
              controller: controller.deliveryAddressController,
              onChanged: (value) => controller.deliveryAddress.value = value,
              icon: Icons.location_on,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Instruções de Entrega (opcional)',
              controller: controller.deliveryInstructionsController,
              onChanged: (value) =>
                  controller.deliveryInstructions.value = value,
              icon: Icons.note,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.canProceedToNextStep()
                    ? controller.nextStep
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _paymentStep(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de Pagamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 24),
            ...controller.paymentMethods
                .map((method) => _buildPaymentOption(context, method)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.canProceedToNextStep()
                        ? controller.nextStep
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Continuar',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _reviewStep(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revisar Pedido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 24),
            _buildReviewSection(context, 'Dados Pessoais', [
              'Nome: ${controller.clientName.value}',
              'Email: ${controller.clientEmail.value}',
              'Telefone: ${controller.clientPhone.value}',
              'Endereço: ${controller.deliveryAddress.value}',
              if (controller.deliveryInstructions.value.isNotEmpty)
                'Instruções: ${controller.deliveryInstructions.value}',
            ]),
            const SizedBox(height: 16),
            _buildReviewSection(context, 'Pagamento', [
              'Método: ${controller.getPaymentMethodLabel(controller.selectedPaymentMethod.value)}',
            ]),
            const SizedBox(height: 16),
            _buildOrderItems(context),
            const SizedBox(height: 16),
            _buildOrderSummary(context),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () => controller.submitOrder(Get.context!),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.success(context),
                          foregroundColor: Colors.white,
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Finalizar Pedido',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      )),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.primary(context),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, Map<String, String> method) {
    return Obx(() {
      final isSelected =
          controller.selectedPaymentMethod.value == method['value'];

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => controller.setPaymentMethod(method['value']!),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.primary(context)
                    : AppColors.border(context),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: method['value']!,
                  groupValue: controller.selectedPaymentMethod.value,
                  onChanged: (value) => controller.setPaymentMethod(value!),
                  activeColor: AppColors.primary(context),
                ),
                const SizedBox(width: 12),
                Text(
                  method['label']!,
                  style: TextStyle(
                      fontSize: 16, color: AppColors.onSurface(context)),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildReviewSection(
      BuildContext context, String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    item,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.onSurface(context)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens do Pedido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 12),
            ...controller.orderItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      if (item.productImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName ?? 'Produto',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface(context)),
                            ),
                            Text(
                              '${item.quantity}x R\$ ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant(context)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'R\$ ${item.total.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface(context)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow(context, 'Subtotal',
                'R\$ ${controller.subtotal.value.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow(context, 'Frete',
                'R\$ ${controller.shipping.value.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _policyHints(context),
            const Divider(height: 24),
            _buildSummaryRow(
              context,
              'Total',
              'R\$ ${controller.total.value.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _policyHints(BuildContext context) {
    return Obx(() {
      final cart = controller.cartController;
      final min = cart.currentMinOrderValue;
      final taxa = cart.vendorTaxaEntrega.value;
      final gratisAcima = cart.vendorLimiteEntregaGratis.value;

      final List<Widget> lines = [];
      if (min > 0) {
        lines.add(_hintLine(context,
            'Pedido mínimo do vendedor: R\$ ${min.toStringAsFixed(2)}'));
      }
      if (taxa > 0) {
        lines.add(_hintLine(
            context, 'Taxa de entrega: R\$ ${taxa.toStringAsFixed(2)}'));
      } else {
        lines.add(_hintLine(context, 'Entrega grátis'));
      }
      if (gratisAcima > 0) {
        lines.add(_hintLine(context,
            'Frete grátis acima de R\$ ${gratisAcima.toStringAsFixed(2)}'));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines,
      );
    });
  }

  Widget _hintLine(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant(context),
          ),
        ),
      ),
    );
  }
}
