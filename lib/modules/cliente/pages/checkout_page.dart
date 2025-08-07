import 'package:flutter/material.dart';
import '../widgets/client_bottom_nav.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(child: Text('Checkout (em breve)')),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 1),
    );
  }
}