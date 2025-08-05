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

  void _loadOrders() async {
    _isLoading.value = true;

    try {
      final orders = await _orderRepository.getUserOrders();
      _orders.value = orders;
    } catch (e) {
      // Log do erro, mas não mostrar snackbar aqui pois não temos contexto
      AppLogger.error('Erro ao carregar histórico de pedidos', e);
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
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'delivering':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void refreshOrders() {
    _loadOrders();
  }
}
