import 'package:flutter/material.dart';

class VendorProductListPage extends StatelessWidget {
  const VendorProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Produtos')),
      body: Center(child: Text('Lista de produtos do vendedor (em breve)')),
    );
  }
} 