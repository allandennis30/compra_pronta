import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../widgets/client_bottom_nav.dart';
import '../../../constants/app_constants.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirecionar automaticamente para o histórico após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      print('🔄 [SUCCESS] Redirecionando para histórico de pedidos...');
      Get.offAllNamed('/cliente/historico');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido Confirmado',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _body(),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 2),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _successIcon,
          const SizedBox(height: 24),
          _successTitle,
          const SizedBox(height: 16),
          _successMessage(),
          const SizedBox(height: 32),
          _actionButtons,
        ],
      ),
    );
  }

  Widget get _successIcon => Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(AppConstants.successColor),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 60,
          color: Colors.white,
        ),
      );

  Widget get _successTitle => const Text(
        'Pedido Confirmado!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.successColor),
        ),
        textAlign: TextAlign.center,
      );

  Widget _successMessage() => const Text(
        'Seu pedido foi realizado com sucesso e está sendo processado.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      );

  Widget _orderDetails(Map<String, dynamic> orderData) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalhes do Pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Status', 'Pendente'),
              _buildDetailRow('Total',
                  'R\$ ${orderData['total']?.toStringAsFixed(2) ?? '0.00'}'),
              _buildDetailRow('Método de Pagamento',
                  _getPaymentMethodLabel(orderData['paymentMethod'] ?? '')),
              if (orderData['deliveryAddress'] != null)
                _buildDetailRow(
                    'Endereço de Entrega', orderData['deliveryAddress']),
              const SizedBox(height: 16),
              const Text(
                'O vendedor será notificado e entrará em contato em breve.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );

  Widget get _actionButtons => Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.offAllNamed('/cliente/products'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Continuar Comprando',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.offAllNamed('/cliente/orders'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(AppConstants.primaryColor)),
              ),
              child: const Text(
                'Ver Meus Pedidos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.primaryColor),
                ),
              ),
            ),
          ),
        ],
      );

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'dinheiro':
        return 'Dinheiro';
      case 'pix':
        return 'PIX';
      case 'cartao_credito':
        return 'Cartão de Crédito';
      case 'cartao_debito':
        return 'Cartão de Débito';
      default:
        return method;
    }
  }
}
