import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/models/order_model.dart';
import '../repositories/order_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';

class OrderHistoryController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  @override
  void onReady() {
    super.onReady();
    // Recarregar pedidos quando a página estiver pronta
    // Isso garante que novos pedidos apareçam imediatamente
    _loadOrders();
  }

  void _loadOrders() async {
    _isLoading.value = true;

    try {
      final orders = await _orderRepository.getUserOrders();
      _orders.value = orders;
    } catch (e) {
      // Log do erro, mas não mostrar snackbar aqui pois não temos contexto
      AppLogger.error('❌ [HISTORY] Erro ao carregar histórico de pedidos', e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> repeatOrder(String orderId, BuildContext context) async {
    try {
      // Verificar se o pedido existe
      _orders.firstWhere((order) => order.id == orderId);
      // TODO: Implementar lógica para repetir pedido
      SnackBarUtils.showSuccess(context, 'Pedido adicionado ao carrinho!');
    } catch (e) {
      SnackBarUtils.showError(context, 'Erro ao repetir pedido: $e');
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'delivering':
        return 'Em entrega';
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
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'confirmed':
        return const Color(0xFF2196F3); // Blue
      case 'preparing':
        return const Color(0xFF2196F3); // Blue
      case 'delivering':
        return const Color(0xFF2196F3); // Blue
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  void refreshOrders() {
    _loadOrders();
  }
}
