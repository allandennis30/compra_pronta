import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/delivery_confirmation_controller.dart';

class DeliveryConfirmationPage extends StatefulWidget {
  const DeliveryConfirmationPage({Key? key}) : super(key: key);

  @override
  State<DeliveryConfirmationPage> createState() => _DeliveryConfirmationPageState();
}

class _DeliveryConfirmationPageState extends State<DeliveryConfirmationPage> {
  final DeliveryConfirmationController controller = Get.put(DeliveryConfirmationController());
  MobileScannerController? scannerController;
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    controller.resetState();
    scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Entrega'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => scannerController?.toggleTorch(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isSuccess.value) {
          return _buildSuccessView();
        }
        
        return Stack(
          children: [
            // Scanner
            if (isScanning) _buildScanner(),
            
            // Overlay com instruções
            _buildOverlay(),
            
            // Loading indicator
            if (controller.isLoading.value) _buildLoadingOverlay(),
            
            // Error message
            if (controller.errorMessage.isNotEmpty) _buildErrorMessage(),
          ],
        );
      }),
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
      controller: scannerController,
      onDetect: (capture) {
        if (!isScanning || controller.isLoading.value) return;
        
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            setState(() {
              isScanning = false;
            });
            controller.confirmDelivery(barcode.rawValue!);
            break;
          }
        }
      },
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          // Área de escaneamento
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          
          // Instruções
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.orange,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Escaneie o QR Code de Confirmação',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Posicione o QR Code dentro da área destacada',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Botão para tentar novamente
          if (!isScanning && !controller.isLoading.value)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanning = true;
                  });
                  controller.resetState();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tentar Novamente'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Confirmando entrega...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                controller.errorMessage.value = '';
                setState(() {
                  isScanning = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      color: Colors.green,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              controller.successMessage.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Entrega confirmada com sucesso!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}