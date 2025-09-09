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
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  final TextEditingController _manualInputController = TextEditingController();
  String? _lastScannedBarcode; // Para prevenir múltiplos escaneamentos

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

    if (_isProcessing) return;

    // Chamar o callback diretamente para entrada manual
    widget.onBarcodeDetected(barcode.trim());
    
    // Voltar para a página anterior (cadastro de produto)
    Get.back();
  }

  void _processBarcode(String barcode) async {
    if (_isProcessing) return;
    
    // Prevenir múltiplos escaneamentos do mesmo código
    if (_lastScannedBarcode == barcode) return;

    setState(() {
      _isProcessing = true;
      _lastScannedBarcode = barcode;
    });

    // Preencher o campo manual com o código escaneado
    _manualInputController.text = barcode;

    // Chamar o callback
    widget.onBarcodeDetected(barcode);

    // Aguarda um pouco para mostrar o feedback visual
    await Future.delayed(const Duration(milliseconds: 500));

    // Voltar para a página anterior (cadastro de produto)
    if (mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Controles da câmera
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                        tooltip: 'Voltar',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Escanear Código de Barras',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
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
            // Câmera com altura flexível para evitar overflow
            Flexible(
              flex: 1,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      if (_isProcessing) return;

                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final Barcode barcode = barcodes.first;
                        if (barcode.rawValue != null) {
                          _processBarcode(barcode.rawValue!);
                        }
                      }
                    },
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Código Detectado!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Código: ${_manualInputController.text}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Retornando ao cadastro...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Área de instruções e entrada manual
            Flexible(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isProcessing 
                            ? 'Código detectado com sucesso!'
                            : 'Aponte a câmera para o código de barras',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isProcessing
                            ? 'Retornando ao cadastro...'
                            : 'O código será detectado automaticamente e você retornará ao cadastro',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      Text(
                        'Ou digite manualmente:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _manualInputController,
                              decoration: InputDecoration(
                                hintText: _manualInputController.text.isEmpty 
                                    ? 'Digite o código de barras' 
                                    : 'Código escaneado: ${_manualInputController.text}',
                                hintStyle: const TextStyle(fontSize: 16),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 16),
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
                              minimumSize: const Size(0, 40),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('OK', style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
