import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../repositories/order_repository.dart';
import '../../../core/utils/logger.dart';

class QRDisplayController extends GetxController {
  final RxBool _isLoading = false.obs;
  final RxBool _isWaitingForDelivery = true.obs;
  final RxString _qrData = ''.obs;
  final Rx<OrderModel?> _order = Rx<OrderModel?>(null);
  
  Timer? _qrRefreshTimer;
  Timer? _orderStatusTimer;
  
  OrderModel? _currentOrder;

  bool get isLoading => _isLoading.value;
  bool get isWaitingForDelivery => _isWaitingForDelivery.value;
  String get qrData => _qrData.value;
  OrderModel? get currentOrder => _currentOrder;

  void initializeOrder(OrderModel order) {
    _currentOrder = order;
    _order.value = order;
    _generateQRData();
  }

  void _initializeOrder() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is OrderModel) {
      initializeOrder(arguments);
    }
  }

  void _generateQRData() {
    if (_currentOrder == null) return;
    
    try {
      _isLoading.value = true;
      
      // Criar dados do QR Code com id do pedido e hash de segurança
      final qrPayload = {
        'order_id': _currentOrder!.id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': 'delivery_confirmation',
        'hash': _generateSecurityHash(_currentOrder!.id),
      };
      
      // Converter para JSON
      _qrData.value = jsonEncode(qrPayload);
      
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar(
        'Erro',
        'Erro ao gerar QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _generateSecurityHash(String orderId) {
    // Gerar um hash simples para validação
    // Em produção, usar uma chave secreta compartilhada com o backend
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$orderId-$timestamp-mercax-security';
    
    // Hash simples (em produção usar crypto mais robusto)
    int hash = 0;
    for (int i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash + data.codeUnitAt(i)) & 0xffffffff;
    }
    
    return hash.abs().toString();
  }

  void onDeliveryConfirmed() {
    _isWaitingForDelivery.value = false;
    
    Get.snackbar(
      'Entrega Confirmada!',
      'Seu pedido foi entregue com sucesso',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
    
    // Voltar para a tela anterior após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }

  void refreshQRCode() {
    if (_currentOrder != null) {
      _generateQRData();
    }
  }

  /// Iniciar timer para atualizar QR Code periodicamente
  void _startQRRefreshTimer() {
    _qrRefreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _generateQRData();
    });
  }

  /// Iniciar listener para verificar status do pedido
  void _startOrderStatusListener() {
    _orderStatusTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkOrderStatus();
    });
  }

  /// Verificar status atual do pedido
  Future<void> _checkOrderStatus() async {
    try {
      if (_order.value == null) return;
      
      final orderRepository = Get.find<OrderRepository>();
      final updatedOrder = await orderRepository.getOrderById(_order.value!.id);
      
      if (updatedOrder != null && updatedOrder.status != _order.value!.status) {
        _order.value = updatedOrder;
        
        // Se o pedido foi entregue, mostrar notificação e voltar
        if (updatedOrder.status == 'delivered') {
          _orderStatusTimer?.cancel();
          _qrRefreshTimer?.cancel();
          
          Get.snackbar(
            'Entrega Confirmada!',
            'Seu pedido foi entregue com sucesso',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            duration: const Duration(seconds: 3),
          );
          
          // Aguardar um pouco e voltar para a página anterior
          await Future.delayed(const Duration(seconds: 2));
          Get.back();
        }
      }
    } catch (e) {
      AppLogger.error('Erro ao verificar status do pedido', e);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeOrder();
    _generateQRData();
    _startQRRefreshTimer();
    _startOrderStatusListener();
  }

  @override
  void onClose() {
    _qrRefreshTimer?.cancel();
    _orderStatusTimer?.cancel();
    _isLoading.close();
    _isWaitingForDelivery.close();
    _qrData.close();
    _order.close();
    super.onClose();
  }
}