import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../repositories/vendor_order_repository.dart';

class VendorOrderDetailController extends GetxController {
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
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'delivering',
    'delivered',
    'cancelled'
  ];

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<VendorOrderRepository>();
    _loadOrderFromParameters();
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
      AppLogger.error('ID do pedido não fornecido na navegação');
    }
  }

  Future<void> loadOrderDetails(String orderId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      AppLogger.info(
          '🔄 [VENDOR_ORDER] Carregando detalhes do pedido: $orderId');

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
            istore: false,
          );
          AppLogger.info(
              '✅ [VENDOR_ORDER] Cliente carregado: ${_customer.value?.name}');
        } else {
          AppLogger.warning(
              '⚠️ [VENDOR_ORDER] Informações do cliente não disponíveis no pedido');
        }

        AppLogger.info(
            '✅ [VENDOR_ORDER] Pedido carregado com sucesso: ${order.id}');
        AppLogger.info('📍 [VENDOR_ORDER] Endereço do pedido:');
        AppLogger.info('   - Street: ${order.deliveryAddress.street}');
        AppLogger.info('   - Number: ${order.deliveryAddress.number}');
        AppLogger.info(
            '   - Neighborhood: ${order.deliveryAddress.neighborhood}');
        AppLogger.info('   - City: ${order.deliveryAddress.city}');
        AppLogger.info('   - State: ${order.deliveryAddress.state}');
        AppLogger.info('   - ZipCode: ${order.deliveryAddress.zipCode}');
        AppLogger.info(
            '   - FullAddress: ${order.deliveryAddress.fullAddress}');
      } else {
        _errorMessage.value = 'Pedido não encontrado';
        AppLogger.warning('⚠️ [VENDOR_ORDER] Pedido não encontrado: $orderId');
      }
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar detalhes do pedido: $e';
      AppLogger.error('❌ [VENDOR_ORDER] Erro ao carregar pedido', e);
    } finally {
      _isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }

  void refreshOrder() {
    if (_order.value != null) {
      loadOrderDetails(_order.value!.id);
    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
    if (_order.value == null) return;

    try {
      _isUpdatingStatus.value = true;

      AppLogger.info(
          '🔄 [VENDOR_ORDER] Atualizando status do pedido ${_order.value!.id} para $newStatus');

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

      AppLogger.info('✅ [VENDOR_ORDER] Status atualizado com sucesso');
      Get.snackbar(
        'Sucesso',
        'Status atualizado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('❌ [VENDOR_ORDER] Erro ao atualizar status do pedido', e);
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
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'ready':
        return 'Pronto';
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
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'confirmed':
        return const Color(0xFF2196F3); // Blue
      case 'preparing':
        return const Color(0xFF9C27B0); // Purple
      case 'ready':
        return const Color(0xFF4CAF50); // Green
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

    final order = _order.value!;
    final customer = _customer.value;

    String message = '*Detalhes do Pedido #${order.id}*\n\n';
    message += '*Cliente:* ${customer?.name ?? 'N/A'}\n';
    message += '*Telefone:* ${customer?.phone ?? 'N/A'}\n\n';
    message +=
        '*Endereço de Entrega:*\n${order.deliveryAddress.fullAddress}\n\n';
    message += '*Itens:*\n';

    for (final item in order.items) {
      message +=
          '• ${item.productName} - Qtd: ${item.quantity} - R\$ ${item.price.toStringAsFixed(2)}\n';
    }

    message += '\n*Subtotal:* R\$ ${order.subtotal.toStringAsFixed(2)}\n';
    message +=
        '*Taxa de Entrega:* R\$ ${order.deliveryFee.toStringAsFixed(2)}\n';
    message += '*Total:* R\$ ${order.total.toStringAsFixed(2)}\n\n';
    message += '*Status:* ${getStatusDisplayName(order.status)}\n';
    message += '*Data do Pedido:* ${_formatDateTime(order.createdAt)}';

    if (order.deliveredAt != null) {
      message += '\n*Data de Entrega:* ${_formatDateTime(order.deliveredAt!)}';
    }

    // Simular compartilhamento (implementar com share_plus)
    Get.snackbar(
      'Sucesso',
      'Detalhes copiados para compartilhamento!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    AppLogger.info('Compartilhando pedido: ${order.id}');
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
