import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../widgets/client_bottom_nav.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/logger.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        AppLogger.info('🔄 [SUCCESS] Redirecionando para histórico de pedidos...');
        Get.offAllNamed('/cliente', arguments: {'initialIndex': 2});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Botões removidos - apenas mensagem de confirmação
        ],
      ),
    );
  }

  Widget get _successIcon => Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          color: Color(AppConstants.successColor),
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

  Widget _successMessage() => Column(
        children: [
          const Text(
            'Seu pedido foi realizado com sucesso e está sendo processado.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'O vendedor será notificado e entrará em contato em breve.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Você será redirecionado automaticamente em $_countdown segundos...',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  // Métodos de detalhes do pedido removidos - não utilizados na versão simplificada

  // Botões de ação removidos - tela deve ter apenas a mensagem de confirmação

  // Método _getPaymentMethodLabel removido - não utilizado na versão simplificada
}
