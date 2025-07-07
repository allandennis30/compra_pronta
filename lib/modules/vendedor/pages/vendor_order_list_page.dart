import 'package:flutter/material.dart';

class VendorOrderListPage extends StatelessWidget {
  const VendorOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: Center(child: Text('Lista de pedidos (em breve)')),
    );
  }
} 