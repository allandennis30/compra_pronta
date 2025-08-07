import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class ScannedItem {
  final String barcode;
  final String name;
  final double price;
  int quantity;

  ScannedItem({
    required this.barcode,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class VendorScanController extends GetxController {
  final RxList<ScannedItem> _scannedItems = <ScannedItem>[].obs;
  final RxBool _isScanning = false.obs;
  final RxString _lastScannedCode = ''.obs;

  List<ScannedItem> get scannedItems => _scannedItems;
  bool get isScanning => _isScanning.value;
  String get lastScannedCode => _lastScannedCode.value;

  double get total => _scannedItems.fold(0, (sum, item) => sum + item.total);

  void processBarcode(String barcode) {
    _lastScannedCode.value = barcode;

    // Simular busca do produto pelo código de barras
    final product = _findProductByBarcode(barcode);

    if (product != null) {
      _addScannedItem(product);
      Get.snackbar(
        'Produto Encontrado',
        '${product['name']} - R\$ ${product['price'].toStringAsFixed(2)}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Produto Não Encontrado',
        'Código: $barcode',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Map<String, dynamic>? _findProductByBarcode(String barcode) {
    // Buscar nos produtos mock
    try {
      return AppConstants.mockProducts.firstWhere(
        (product) => product['barcode'] == barcode,
      );
    } catch (e) {
      return null;
    }
  }

  // Método público para buscar produto por código de barras
  Map<String, dynamic>? findProductByBarcode(String barcode) {
    return _findProductByBarcode(barcode);
  }

  void _addScannedItem(Map<String, dynamic> product) {
    final existingIndex = _scannedItems.indexWhere(
      (item) => item.barcode == product['barcode'],
    );

    if (existingIndex >= 0) {
      _scannedItems[existingIndex].quantity++;
    } else {
      _scannedItems.add(ScannedItem(
        barcode: product['barcode'],
        name: product['name'],
        price: product['price'].toDouble(),
      ));
    }
  }

  void updateQuantity(String barcode, int quantity) {
    if (quantity <= 0) {
      _scannedItems.removeWhere((item) => item.barcode == barcode);
      return;
    }

    final index = _scannedItems.indexWhere((item) => item.barcode == barcode);
    if (index >= 0) {
      _scannedItems[index].quantity = quantity;
    }
  }

  void removeItem(String barcode) {
    _scannedItems.removeWhere((item) => item.barcode == barcode);
  }

  void clearScannedItems() {
    _scannedItems.clear();
  }

  void toggleScanning() {
    _isScanning.value = !_isScanning.value;
  }

  void generateReport() {
    if (_scannedItems.isEmpty) {
      Get.snackbar(
        'Relatório Vazio',
        'Nenhum item escaneado para gerar relatório',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Simular geração de relatório
    final report = _generateReportText();

    Get.dialog(
      AlertDialog(
        title: const Text('Relatório de Embalagem'),
        content: SingleChildScrollView(
          child: Text(report),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Compartilhar relatório
              Get.back();
              Get.snackbar(
                'Relatório Compartilhado',
                'Relatório enviado com sucesso!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  String _generateReportText() {
    final buffer = StringBuffer();
    buffer.writeln('RELATÓRIO DE EMBALAGEM');
    buffer.writeln('Data: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('Total de itens: ${_scannedItems.length}');
    buffer.writeln('Valor total: R\$ ${total.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('ITENS ESCANEADOS:');
    buffer.writeln('');

    for (final item in _scannedItems) {
      buffer.writeln(item.name);
      buffer.writeln('  Código: ${item.barcode}');
      buffer.writeln('  Quantidade: ${item.quantity}');
      buffer.writeln('  Preço unitário: R\$ ${item.price.toStringAsFixed(2)}');
      buffer.writeln('  Subtotal: R\$ ${item.total.toStringAsFixed(2)}');
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
