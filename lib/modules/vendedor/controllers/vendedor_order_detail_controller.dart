import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mercax/core/utils/logger.dart';
import 'dart:async';
import '../../../core/models/order_model.dart';
import '../../../core/models/user_model.dart';
import '../repositories/vendor_order_repository.dart';
import 'vendor_order_list_controller.dart';
import 'vendor_metrics_controller.dart';
import 'sales_report_controller.dart';

class VendedorOrderDetailController extends GetxController {
  late final VendorOrderRepository _repository;
  final Rx<OrderModel?> _order = Rx<OrderModel?>(null);
  final Rx<UserModel?> _customer = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isUpdatingStatus = false.obs;
  final RxString _errorMessage = ''.obs;

  OrderModel? get order => _order.value;
  UserModel? get customer => _customer.value;
  bool get isLoading => _isLoading.value;
  bool get isUpdatingStatus => _isUpdatingStatus.value;
  String get errorMessage => _errorMessage.value;

  final List<String> availableStatuses = [
    'preparing',
    'delivering',
    'delivered',
    'cancelled'
  ];

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<VendorOrderRepository>();
    _loadOrderFromParameters();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _stopAutoRefresh();
    super.onClose();
  }

  Timer? _autoRefreshTimer;

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshOrderSilently();
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  void _loadOrderFromParameters() {
    // Verificar parâmetros da rota primeiro
    String? orderId = Get.parameters['orderId'];

    // Se não encontrar nos parâmetros, verificar nos argumentos
    if (orderId == null) {
      final arguments = Get.arguments;
      if (arguments is String) {
        orderId = arguments;
      } else if (arguments is Map && arguments.containsKey('orderId')) {
        orderId = arguments['orderId']?.toString();
      }
    }

    if (orderId != null && orderId.isNotEmpty) {
      loadOrderDetails(orderId);
    } else {
      _errorMessage.value = 'ID do pedido não fornecido';

    }
  }

  Future<void> loadOrderDetails(String orderId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';



      final order = await _repository.getOrderById(orderId);
      if (order != null) {
        _order.value = order;

        // Carregar informações do cliente a partir do pedido
        if (order.clientName != null ||
            order.clientEmail != null ||
            order.clientPhone != null) {
          _customer.value = UserModel(
            id: order.userId,
            name: order.clientName ?? 'Cliente não identificado',
            email: order.clientEmail ?? '',
            phone: order.clientPhone ?? '',
            address: order.deliveryAddress,
            latitude: 0.0, // Não disponível no pedido
            longitude: 0.0, // Não disponível no pedido
            isSeller: false,
          );
        }
      } else {
        _errorMessage.value = 'Pedido não encontrado';

      }
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar detalhes do pedido: $e';

    } finally {
      _isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }

  void navigateToOrderBuilder() {
    if (_order.value != null) {
      Get.toNamed('/vendor/order-builder', arguments: {
        'orderId': _order.value!.id,
        'order': _order.value!,
      });
    }
  }

  void refreshOrder() {
    if (_order.value != null) {
      loadOrderDetails(_order.value!.id);
    }
  }

  Future<void> _refreshOrderSilently() async {
    if (_order.value == null || _isUpdatingStatus.value) return;
    try {
      final latest = await _repository.getOrderById(_order.value!.id);
      if (latest == null) return;
      if (latest.status != _order.value!.status ||
          latest.updatedAt != _order.value!.updatedAt) {
        _order.value = latest;

      }
    } catch (e) {
      // silencioso

    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
    if (_order.value == null) return;

    try {
      _isUpdatingStatus.value = true;



      await _repository.updateOrderStatus(_order.value!.id, newStatus);

      // Atualizar o pedido localmente
      final updatedOrder = OrderModel(
        id: _order.value!.id,
        userId: _order.value!.userId,
        items: _order.value!.items,
        subtotal: _order.value!.subtotal,
        deliveryFee: _order.value!.deliveryFee,
        total: _order.value!.total,
        status: newStatus,
        createdAt: _order.value!.createdAt,
        deliveredAt: newStatus == 'delivered'
            ? DateTime.now()
            : _order.value!.deliveredAt,
        deliveryAddress: _order.value!.deliveryAddress,
      );

      _order.value = updatedOrder;


      Get.snackbar(
        'Sucesso',
        'Status atualizado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _notifyOrderStatusChanged(updatedOrder);
    } catch (e) {

      Get.snackbar(
        'Erro',
        'Erro ao atualizar status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  String getStatusDisplayName(String status) {
    switch (status) {
      case 'preparing':
        return 'Preparando';
      case 'delivering':
        return 'Saiu para entrega';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    // Note: This method should ideally receive a BuildContext to access theme
    // For now, using Material Design default colors that work in both themes
    switch (status) {
      case 'preparing':
        return const Color(0xFF9C27B0); // Purple
      case 'delivering':
        return const Color(0xFF009688); // Teal
      case 'delivered':
        return const Color(0xFF388E3C); // Dark Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  void shareOrderDetails() {
    if (_order.value == null) return;


    // Simular compartilhamento (implementar com share_plus)
    Get.snackbar(
      'Sucesso',
      'Detalhes copiados para compartilhamento!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }


  /// Gerar QR Code para confirmação de entrega
  Future<String?> generateDeliveryQRCode() async {
    if (_order.value == null) return null;

    try {
      final qrData = await _repository.generateDeliveryQRCode(_order.value!.id);
      return qrData['qrCodeData'];
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao gerar QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Notifica outros controllers sobre a mudança de status do pedido
  void _notifyOrderStatusChanged(OrderModel updatedOrder) {
    try {
      // Notificar o controller da lista de pedidos
      if (Get.isRegistered<VendorOrderListController>()) {
        final orderListController = Get.find<VendorOrderListController>();
        orderListController.updateOrderInList(updatedOrder);
      }

      // Notificar o controller de métricas
      if (Get.isRegistered<VendorMetricsController>()) {
        final metricsController = Get.find<VendorMetricsController>();
        metricsController.updateOrderInMetrics(updatedOrder);
      }

      // Notificar o controller de relatórios de vendas
      if (Get.isRegistered<SalesReportController>()) {
        final salesReportController = Get.find<SalesReportController>();
        salesReportController.updateOrderInReport(updatedOrder);
      }


    } catch (e) {
      AppLogger.error('❌ [ORDER] Erro ao notificar mudança de status', e);
    }
  }
}
