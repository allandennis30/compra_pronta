import 'package:flutter/material.dart';
import '../../../utils/logger.dart';
import 'package:get/get.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../../constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class DeliveryManagementController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  String? _baseUrl;

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> deliveryUsers = <Map<String, dynamic>>[].obs;
  final RxString qrCodeData = ''.obs;
  final RxBool showQRCode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeBaseUrl();
  }

  Future<void> _initializeBaseUrl() async {
    _baseUrl = await AppConstants.baseUrl;
    loadDeliveryUsers();
    generateQRCode();
  }

  /// Carregar lista de entregadores da loja
  Future<void> loadDeliveryUsers() async {
    try {
      isLoading.value = true;
      
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      // Obter o ID do vendedor atual
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null || !currentUser.isSeller) {
        throw Exception('Usuário não é um vendedor válido');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/delivery/manage/${currentUser.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      AppLogger.info('Response status: ${response.statusCode}');
      AppLogger.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final responseData = data['data'];
          deliveryUsers.value = List<Map<String, dynamic>>.from(responseData['deliveryUsers'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Erro ao carregar entregadores');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao carregar entregadores');
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar entregadores: $e');
      Get.snackbar(
        'Erro',
        'Erro ao carregar entregadores: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Gerar QR Code para registro de entregador
  Future<void> generateQRCode() async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      // Decodificar o token para obter o ID do vendedor
      final payload = _decodeJWT(token);
      final sellerId = payload['id'];
      
      if (sellerId == null) {
        throw Exception('ID do vendedor não encontrado no token');
      }

      // Gerar dados do QR Code
      qrCodeData.value = 'delivery_register:$sellerId';
      
      AppLogger.info('QR Code gerado: ${qrCodeData.value}');
    } catch (e) {
      AppLogger.error('Erro ao gerar QR Code: $e');
      Get.snackbar(
        'Erro',
        'Erro ao gerar QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Remover entregador da loja
  Future<void> removeDeliveryUser(String deliveryUserId) async {
    try {
      isLoading.value = true;
      
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      // Obter o ID do vendedor atual
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null || !currentUser.isSeller) {
        throw Exception('Usuário não é um vendedor válido');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/delivery/manage/${currentUser.id}/$deliveryUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      AppLogger.info('Response status: ${response.statusCode}');
      AppLogger.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Recarregar lista
          await loadDeliveryUsers();
          
          Get.snackbar(
            'Sucesso',
            'Entregador removido com sucesso!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(data['message'] ?? 'Erro ao remover entregador');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao remover entregador');
      }
    } catch (e) {
      AppLogger.error('Erro ao remover entregador: $e');
      Get.snackbar(
        'Erro',
        'Erro ao remover entregador: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Alternar exibição do QR Code
  void toggleQRCode() {
    showQRCode.value = !showQRCode.value;
  }

  /// Gerar QR Code para confirmação de entrega
  String generateDeliveryConfirmationQR(String orderId) {
    final confirmationCode = _generateConfirmationCode();
    return 'delivery_confirm:$orderId:$confirmationCode';
  }

  /// Decodificar JWT (versão simples)
  Map<String, dynamic> _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token JWT inválido');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded);
    } catch (e) {
      AppLogger.error('Erro ao decodificar JWT: $e');
      throw Exception('Erro ao decodificar token');
    }
  }

  /// Gerar código de confirmação aleatório
  String _generateConfirmationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    
    for (int i = 0; i < 6; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  /// Widget para exibir QR Code
  Widget buildQRCodeWidget() {
    if (qrCodeData.value.isEmpty) {
      return const Center(
        child: Text(
          'QR Code não disponível',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'QR Code para Registro de Entregador',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: qrCodeData.value,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mostre este código para o entregador escanear',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Mostrar dialog de confirmação para remover entregador
  void showRemoveConfirmationDialog(String deliveryUserId, String deliveryUserName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remover Entregador'),
        content: Text(
          'Tem certeza que deseja remover "$deliveryUserName" da lista de entregadores?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              removeDeliveryUser(deliveryUserId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}