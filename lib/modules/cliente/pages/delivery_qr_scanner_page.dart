import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../controllers/delivery_controller.dart';
import '../repositories/order_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/api_service.dart';

class DeliveryQRScannerPage extends StatefulWidget {
  const DeliveryQRScannerPage({super.key});

  @override
  State<DeliveryQRScannerPage> createState() => _DeliveryQRScannerPageState();
}

class _DeliveryQRScannerPageState extends State<DeliveryQRScannerPage> {
  final DeliveryController _deliveryController = Get.find<DeliveryController>();
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  bool _isScanning = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Entrega'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),

            // Título
            Text(
              'Escanear QR Code do Cliente',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Descrição
            Text(
              'Escaneie o QR Code fornecido pelo cliente para confirmar a entrega do pedido.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Botão de escanear
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning || _isProcessing
                    ? null
                    : _scanQRCode,
                icon: _isScanning || _isProcessing
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
                      : _isProcessing
                          ? 'Processando...'
                          : 'Escanear QR Code',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instruções
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Instruções:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Posicione a câmera sobre o QR Code\n'
                    '• Mantenha o dispositivo estável\n'
                    '• Certifique-se de ter boa iluminação\n'
                    '• Confirme se é o pedido correto\n'
                    '• O cliente deve mostrar o QR Code gerado no app',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
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
        _showErrorSnackbar('Permissão da câmera é necessária para escanear QR Code');
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
        _showErrorSnackbar('QR Code inválido');
        return;
      }

      // Processar QR Code
      await _processDeliveryConfirmationQR(qrData);
    } catch (e) {
      _showErrorSnackbar('Erro ao escanear QR Code: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _processDeliveryConfirmationQR(String qrData) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Tentar decodificar JSON
      Map<String, dynamic> qrPayload;
      try {
        qrPayload = jsonDecode(qrData);
      } catch (e) {
        _showErrorSnackbar('QR Code não é válido para confirmação de entrega');
        return;
      }

      // Validar estrutura do QR Code
      if (!qrPayload.containsKey('order_id') ||
          !qrPayload.containsKey('type') ||
          qrPayload['type'] != 'delivery_confirmation') {
        _showErrorSnackbar('QR Code não é válido para confirmação de entrega');
        return;
      }

      final orderId = qrPayload['order_id'] as String;
      final hash = qrPayload['hash'] as String?;

      if (orderId.isEmpty) {
        _showErrorSnackbar('ID do pedido não encontrado no QR Code');
        return;
      }

      // Mostrar dialog de confirmação
      final confirmed = await _showConfirmationDialog(orderId);
      if (!confirmed) {
        return;
      }

      // Confirmar entrega no backend
      await _confirmDelivery(orderId, hash);
      
    } catch (e) {
      _showErrorSnackbar('Erro ao processar QR Code: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog(String orderId) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar Entrega'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja confirmar a entrega do pedido?'),
            const SizedBox(height: 8),
            Text(
              'Pedido: #${orderId.substring(0, 8)}...',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _confirmDelivery(String orderId, String? hash) async {
    try {
      // Obter ID do entregador atual
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;
      
      if (currentUser == null) {
        _showErrorSnackbar('Usuário não autenticado');
        return;
      }
      
      // Chamar API para confirmar entrega pelo entregador
      final apiService = Get.find<ApiService>();
      final response = await apiService.post('/orders/$orderId/confirm-delivery-by-deliverer', {
        'delivererId': currentUser.id,
        'hash': hash,
      });
      
      if (response['success'] == true) {
         // Recarregar dados do entregador
         await _deliveryController.loadDeliveryOrders();
         await _deliveryController.loadDeliveryStats();
         
         // Atualizar estatísticas do entregador
         await _updateDelivererStats(currentUser.id);
         
         // Mostrar sucesso
         Get.snackbar(
           'Sucesso!',
           'Entrega confirmada com sucesso! Suas estatísticas foram atualizadas.',
           snackPosition: SnackPosition.BOTTOM,
           backgroundColor: Colors.green,
           colorText: Colors.white,
           icon: const Icon(
             Icons.check_circle,
             color: Colors.white,
           ),
           duration: const Duration(seconds: 4),
         );
         
         // Voltar para a página anterior
         Get.back();
       } else {
        _showErrorSnackbar(response['message'] ?? 'Erro ao confirmar entrega');
      }
      
    } catch (e) {
      _showErrorSnackbar('Erro ao confirmar entrega: $e');
    }
  }

  /// Atualizar estatísticas do entregador após entrega
  Future<void> _updateDelivererStats(String delivererId) async {
    try {
      final apiService = Get.find<ApiService>();
      await apiService.post('/delivery/stats/update', {
        'delivererId': delivererId,
        'action': 'delivery_completed',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log do erro mas não interrompe o fluxo
      print('Erro ao atualizar estatísticas do entregador: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    );
  }
}