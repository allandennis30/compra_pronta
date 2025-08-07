import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_scan_controller.dart';
import '../widgets/barcode_scanner.dart';

class VendorScanPage extends StatelessWidget {
  final VendorScanController controller = Get.put(VendorScanController());

  VendorScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Código de Barras'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildScannerArea(),
          const SizedBox(height: 16),
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildScannerArea() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BarcodeScanner(
          onBarcodeDetected: (barcode) {
            controller.processBarcode(barcode);
            _navigateToProductDetail(barcode);
          },
        ),
      ),
    );
  }

  void _navigateToProductDetail(String barcode) {
    // Buscar produto pelo código de barras
    final product = controller.findProductByBarcode(barcode);
    
    if (product != null) {
      // Navegar para a página de detalhes do produto
      Get.toNamed('/vendor/produto_form', arguments: {
        'product': product,
        'isEditing': true,
      });
    } else {
      // Se produto não encontrado, navegar para cadastro de novo produto
      Get.toNamed('/vendor/produto_form', arguments: {
        'barcode': barcode,
        'isEditing': false,
      });
    }
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Como usar o scanner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aponte a câmera para o código de barras do produto. Após escanear, você será direcionado para a página de detalhes do produto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


}