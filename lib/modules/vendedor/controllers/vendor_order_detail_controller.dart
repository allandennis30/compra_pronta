import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';

class VendorOrderDetailController extends GetxController {
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
    
    if (orderId != null) {
      loadOrderDetails(orderId);
    } else {
      _errorMessage.value = 'ID do pedido não fornecido';
    }
  }

  Future<void> loadOrderDetails(String orderId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simular busca do pedido (substituir por repository real)
      await Future.delayed(Duration(milliseconds: 500));
      
      final mockOrder = _getMockOrder(orderId);
      if (mockOrder != null) {
        _order.value = mockOrder;
        await _loadCustomerDetails(mockOrder.userId);
      } else {
        _errorMessage.value = 'Pedido não encontrado';
      }
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar detalhes do pedido: $e';
      AppLogger.error('Erro ao carregar pedido', e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadCustomerDetails(String userId) async {
    try {
      // Simular busca do cliente (substituir por repository real)
      final mockCustomer = _getMockCustomer(userId);
      _customer.value = mockCustomer;
    } catch (e) {
      AppLogger.error('Erro ao carregar dados do cliente', e);
    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
    if (_order.value == null) return;

    try {
      _isUpdatingStatus.value = true;

      // Simular atualização do status (substituir por repository real)
      await Future.delayed(Duration(milliseconds: 300));

      final updatedOrder = OrderModel(
        id: _order.value!.id,
        userId: _order.value!.userId,
        items: _order.value!.items,
        subtotal: _order.value!.subtotal,
        deliveryFee: _order.value!.deliveryFee,
        total: _order.value!.total,
        status: newStatus,
        createdAt: _order.value!.createdAt,
        deliveredAt: newStatus == 'delivered' ? DateTime.now() : _order.value!.deliveredAt,
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
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      AppLogger.error('Erro ao atualizar status do pedido', e);
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
    message += '*Endereço de Entrega:*\n${order.deliveryAddress.fullAddress}\n\n';
    message += '*Itens:*\n';
    
    for (final item in order.items) {
      message += '• ${item.productName} - Qtd: ${item.quantity} - R\$ ${item.price.toStringAsFixed(2)}\n';
    }
    
    message += '\n*Subtotal:* R\$ ${order.subtotal.toStringAsFixed(2)}\n';
    message += '*Taxa de Entrega:* R\$ ${order.deliveryFee.toStringAsFixed(2)}\n';
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

  // Mock data - substituir por repository real
  OrderModel? _getMockOrder(String orderId) {
    final mockOrders = {
      'order_001': OrderModel(
        id: 'order_001',
        userId: 'user_cliente_001',
        items: [
          OrderItemModel(
            productId: 'prod_001',
            productName: 'Maçã Fuji',
            price: 8.90,
            quantity: 2,
          ),
          OrderItemModel(
            productId: 'prod_002',
            productName: 'Banana Prata',
            price: 4.50,
            quantity: 3,
          ),
          OrderItemModel(
            productId: 'prod_003',
            productName: 'Leite Integral 1L',
            price: 6.90,
            quantity: 1,
          ),
        ],
        subtotal: 35.60,
        deliveryFee: 5.00,
        total: 40.60,
        status: 'confirmed',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        deliveryAddress: AddressModel(
          street: 'Rua das Flores',
          number: '123',
          complement: 'Apto 45',
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01234-567',
        ),
      ),
    };
    return mockOrders[orderId];
  }

  UserModel? _getMockCustomer(String userId) {
    final mockCustomers = {
      'user_cliente_001': UserModel(
        id: 'user_cliente_001',
        name: 'Maria Silva',
        email: 'maria.silva@email.com',
        phone: '(11) 99999-9999',
        address: AddressModel(
          street: 'Rua das Flores',
          number: '123',
          complement: 'Apto 45',
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01234-567',
        ),
        latitude: -23.5505,
        longitude: -46.6333,
        istore: false,
      ),
    };
    return mockCustomers[userId];
  }
}