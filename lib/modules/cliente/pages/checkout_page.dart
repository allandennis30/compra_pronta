import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/client_bottom_nav.dart';
import '../../../constants/app_constants.dart';

class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _body,
      bottomNavigationBar: const ClientBottomNav(currentIndex: 1),
    );
  }

  Widget get _body => Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _stepper,
            Expanded(child: _currentStepContent),
          ],
        );
      });

  Widget get _stepper => Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStep(0, 'Dados', Icons.person),
            _buildStepLine(),
            _buildStep(1, 'Pagamento', Icons.payment),
            _buildStepLine(),
            _buildStep(2, 'Revisão', Icons.check_circle),
          ],
        ),
      );

  Widget _buildStep(int step, String title, IconData icon) {
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
                  ? const Color(AppConstants.successColor)
                  : isActive
                      ? const Color(AppConstants.primaryColor)
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted || isActive ? Colors.white : Colors.grey[600],
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
                  ? const Color(AppConstants.primaryColor)
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      height: 2,
      width: 20,
      color: controller.currentStep.value > 0
          ? Colors.grey[300]
          : Colors.grey[200],
    );
  }

  Widget get _currentStepContent {
    switch (controller.currentStep.value) {
      case 0:
        return _personalDataStep;
      case 1:
        return _paymentStep;
      case 2:
        return _reviewStep;
      default:
        return const SizedBox();
    }
  }

  Widget get _personalDataStep => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados Pessoais',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Nome Completo',
              controller: controller.clientNameController,
              onChanged: (value) => controller.clientName.value = value,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email',
              controller: controller.clientEmailController,
              onChanged: (value) => controller.clientEmail.value = value,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Telefone',
              controller: controller.clientPhoneController,
              onChanged: (value) => controller.clientPhone.value = value,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Endereço de Entrega',
              controller: controller.deliveryAddressController,
              onChanged: (value) => controller.deliveryAddress.value = value,
              icon: Icons.location_on,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
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
                  backgroundColor: const Color(AppConstants.primaryColor),
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

  Widget get _paymentStep => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de Pagamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...controller.paymentMethods
                .map((method) => _buildPaymentOption(method)),
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
                      backgroundColor: const Color(AppConstants.primaryColor),
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

  Widget get _reviewStep => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revisar Pedido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildReviewSection('Dados Pessoais', [
              'Nome: ${controller.clientName.value}',
              'Email: ${controller.clientEmail.value}',
              'Telefone: ${controller.clientPhone.value}',
              'Endereço: ${controller.deliveryAddress.value}',
              if (controller.deliveryInstructions.value.isNotEmpty)
                'Instruções: ${controller.deliveryInstructions.value}',
            ]),
            const SizedBox(height: 16),
            _buildReviewSection('Pagamento', [
              'Método: ${controller.getPaymentMethodLabel(controller.selectedPaymentMethod.value)}',
            ]),
            const SizedBox(height: 16),
            _buildOrderItems(),
            const SizedBox(height: 16),
            _buildOrderSummary(),
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
                          backgroundColor:
                              const Color(AppConstants.successColor),
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
          borderSide: const BorderSide(
            color: Color(AppConstants.primaryColor),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(Map<String, String> method) {
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
                    ? const Color(AppConstants.primaryColor)
                    : Colors.grey[300]!,
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
                  activeColor: const Color(AppConstants.primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  method['label']!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itens do Pedido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${item.quantity}x R\$ ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'R\$ ${item.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal',
                'R\$ ${controller.subtotal.value.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow(
                'Frete', 'R\$ ${controller.shipping.value.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              'R\$ ${controller.total.value.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
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
            color: isTotal ? const Color(AppConstants.successColor) : null,
          ),
        ),
      ],
    );
  }
}
