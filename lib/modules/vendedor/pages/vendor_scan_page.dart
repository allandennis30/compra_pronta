import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_scan_controller.dart';

class VendorScanPage extends StatelessWidget {
  final VendorScanController controller = Get.put(VendorScanController());

  VendorScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Embalagem'),
        actions: [
          Obx(() => controller.scannedItems.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.assessment),
                  onPressed: controller.generateReport,
                )
              : const SizedBox()),
        ],
      ),
      body: Column(
        children: [
          _buildScannerArea(),
          Expanded(child: _buildScannedItems()),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildScannerArea() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Scanner de Código de Barras',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Digite o código manualmente ou use a câmera',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildManualInput(),
        ],
      ),
    );
  }

  Widget _buildManualInput() {
    final textController = TextEditingController();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Digite o código de barras',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.processBarcode(textController.text);
                textController.clear();
              }
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedItems() {
    return Obx(() {
      if (controller.scannedItems.isEmpty) {
        return const Center(
          child: Text(
            'Nenhum item escaneado ainda',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.scannedItems.length,
        itemBuilder: (context, index) {
          final item = controller.scannedItems[index];
          return _buildScannedItemCard(item);
        },
      );
    });
  }

  Widget _buildScannedItemCard(ScannedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            item.quantity.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(item.name),
        subtitle: Text('Código: ${item.barcode}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'R\$ ${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.removeItem(item.barcode),
            ),
          ],
        ),
        onTap: () => _showQuantityDialog(item),
      ),
    );
  }

  Widget _buildSummary() {
    return Obx(() {
      if (controller.scannedItems.isEmpty) {
        return const SizedBox();
      }

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
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total de itens: ${controller.scannedItems.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$ ${controller.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.clearScannedItems,
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.generateReport,
                    child: const Text('Gerar Relatório'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showQuantityDialog(ScannedItem item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    
    Get.dialog(
      AlertDialog(
        title: Text('Quantidade - ${item.name}'),
        content: TextField(
          controller: quantityController,
          decoration: const InputDecoration(
            labelText: 'Quantidade',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              controller.updateQuantity(item.barcode, quantity);
              Get.back();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
} 