import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const BarcodeScanner({
    super.key,
    required this.onBarcodeDetected,
  });

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  late MobileScannerController controller;
  bool _hasDetectedBarcode = false;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _processManualInput(String barcode) {
    if (barcode.trim().isEmpty) {
      Get.snackbar(
        'Código Inválido',
        'Por favor, digite um código de barras válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_hasDetectedBarcode) return;

    setState(() {
      _hasDetectedBarcode = true;
    });

    widget.onBarcodeDetected(barcode.trim());
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controles da câmera
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Escanear Código de Barras',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
                    onPressed: () {
                      controller.toggleTorch();
                      setState(() {
                        _isTorchOn = !_isTorchOn;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
                    onPressed: () {
                      controller.switchCamera();
                      setState(() {
                        _isFrontCamera = !_isFrontCamera;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                if (_hasDetectedBarcode) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final Barcode barcode = barcodes.first;
                  if (barcode.rawValue != null) {
                    setState(() {
                      _hasDetectedBarcode = true;
                    });
                    widget.onBarcodeDetected(barcode.rawValue!);
                    Get.back();
                  }
                }
              },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Aponte a câmera para o código de barras',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'O código será detectado automaticamente',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 6),
                Text(
                  'Ou digite manualmente:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualInputController,
                        decoration: const InputDecoration(
                          hintText: 'Digite o código de barras',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: _processManualInput,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () =>
                          _processManualInput(_manualInputController.text),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('OK', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
