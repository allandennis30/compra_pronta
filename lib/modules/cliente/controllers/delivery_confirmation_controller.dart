import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../repositories/delivery_repository.dart';
import '../../../utils/logger.dart';

class DeliveryConfirmationController extends GetxController {
  final DeliveryRepository _deliveryRepository = Get.find<DeliveryRepository>();
  final AuthController _authController = Get.find<AuthController>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;
  final RxString successMessage = ''.obs;

  /// Confirmar entrega via QR Code
  Future<void> confirmDelivery(String qrCodeData) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;
      
      // Validar se o usuário é entregador
      final user = _authController.currentUser;
      if (user == null || !(user.isEntregador ?? false)) {
        throw Exception('Apenas entregadores podem confirmar entregas');
      }
      
      // Extrair dados do QR Code
      final deliveryData = _parseQRCodeData(qrCodeData);
      
      if (deliveryData == null) {
        throw Exception('QR Code inválido para confirmação de entrega');
      }
      
      // Confirmar entrega no backend
      await _deliveryRepository.confirmDelivery(
        deliveryData['orderId']!,
        deliveryData['deliveryCode']!,
      );
      
      isSuccess.value = true;
      successMessage.value = 'Entrega confirmada com sucesso!';
      
      // Aguardar um pouco para mostrar a mensagem de sucesso
      await Future.delayed(const Duration(seconds: 2));
      
      // Voltar para a tela anterior
      Get.back();
      
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      AppLogger.error('Erro ao confirmar entrega: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Extrair dados do QR Code
  Map<String, String>? _parseQRCodeData(String qrCodeData) {
    try {
      // Formato esperado: "DELIVERY:orderId:deliveryCode"
      if (!qrCodeData.startsWith('DELIVERY:')) {
        return null;
      }
      
      final parts = qrCodeData.split(':');
      if (parts.length != 3) {
        return null;
      }
      
      return {
        'orderId': parts[1],
        'deliveryCode': parts[2],
      };
    } catch (e) {
      AppLogger.error('Erro ao analisar QR Code: $e');
      return null;
    }
  }
  
  /// Resetar estado
  void resetState() {
    isLoading.value = false;
    errorMessage.value = '';
    isSuccess.value = false;
    successMessage.value = '';
  }
}