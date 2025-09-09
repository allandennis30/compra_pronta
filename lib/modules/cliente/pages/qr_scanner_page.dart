import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../controllers/delivery_controller.dart';

class QRScannerPage extends StatefulWidget {
  final String scanType; // 'register' ou 'confirm'
  final String? orderId; // Para confirmação de entrega

  const QRScannerPage({
    Key? key,
    required this.scanType,
    this.orderId,
  }) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final DeliveryController _deliveryController = Get.find<DeliveryController>();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.scanType == 'register'
              ? 'Escanear QR - Registro'
              : 'Escanear QR - Confirmação',
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 60,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),

            // Título
            Text(
              widget.scanType == 'register'
                  ? 'Escaneie o QR Code do Vendedor'
                  : 'Escaneie o QR Code de Confirmação',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Descrição
            Text(
              widget.scanType == 'register'
                  ? 'O vendedor deve gerar um QR Code para você se registrar como entregador da loja.'
                  : 'Escaneie o QR Code fornecido pelo cliente para confirmar a entrega do pedido.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Botão de escanear
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning || _deliveryController.isLoading.value
                        ? null
                        : _scanQRCode,
                    icon: _isScanning || _deliveryController.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.qr_code_scanner),
                    label: Text(
                      _isScanning
                          ? 'Escaneando...'
                          : _deliveryController.isLoading.value
                              ? 'Processando...'
                              : 'Escanear QR Code',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 24),

            // Instruções adicionais
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Instruções:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.scanType == 'register'
                        ? '• Posicione a câmera sobre o QR Code\n• Mantenha o dispositivo estável\n• Certifique-se de ter boa iluminação\n• O QR Code deve estar bem visível'
                        : '• Posicione a câmera sobre o QR Code\n• Mantenha o dispositivo estável\n• Certifique-se de ter boa iluminação\n• Confirme se é o pedido correto',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanQRCode() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Verificar permissão da câmera
      final hasPermission = await _deliveryController.checkCameraPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Erro',
          'Permissão da câmera é necessária para escanear QR Code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Escanear QR Code
      final result = await BarcodeScanner.scan();

      if (result.type == ResultType.Cancelled) {
        Get.snackbar(
          'Info',
          'Escaneamento cancelado',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final qrData = result.rawContent;
      if (qrData.isEmpty) {
        Get.snackbar(
          'Erro',
          'QR Code inválido',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Processar QR Code baseado no tipo
      if (widget.scanType == 'register') {
        await _processRegistrationQR(qrData);
      } else if (widget.scanType == 'confirm' && widget.orderId != null) {
        await _processConfirmationQR(qrData, widget.orderId!);
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao escanear QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _processRegistrationQR(String qrData) async {
    // Validar formato do QR Code de registro
    if (!qrData.startsWith('delivery_register:')) {
      Get.snackbar(
        'Erro',
        'QR Code não é válido para registro de entregador',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final sellerId = qrData.replaceFirst('delivery_register:', '');
    if (sellerId.isEmpty) {
      Get.snackbar(
        'Erro',
        'ID do vendedor não encontrado no QR Code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Usar o método público do controller
      await _deliveryController.registerAsDelivery(sellerId);
      
      // Carregar dados de entrega
      await _deliveryController.loadDeliveryStores();
      
      Get.snackbar(
        'Sucesso',
        'Registrado como entregador com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Voltar para a página anterior
      Get.back();
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao registrar como entregador: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _processConfirmationQR(String qrData, String orderId) async {
    // Validar formato do QR Code de confirmação
    if (!qrData.startsWith('delivery_confirm:')) {
      Get.snackbar(
        'Erro',
        'QR Code não é válido para confirmação de entrega',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final parts = qrData.split(':');
    if (parts.length != 3) {
      Get.snackbar(
        'Erro',
        'Formato do QR Code inválido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final qrOrderId = parts[1];
    final confirmationCode = parts[2];

    if (qrOrderId != orderId) {
      Get.snackbar(
        'Erro',
        'QR Code não corresponde ao pedido selecionado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Confirmar entrega
      await _deliveryController.confirmDelivery(orderId, confirmationCode);
      
      // Recarregar pedidos
      await _deliveryController.loadDeliveryOrders();
      
      Get.snackbar(
        'Sucesso',
        'Entrega confirmada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Voltar para a página anterior
      Get.back();
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao confirmar entrega: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}