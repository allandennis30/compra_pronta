import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/models/order_model.dart';
import '../repositories/order_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/snackbar_utils.dart';

class OrderHistoryController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _confirmingOrderId = ''.obs;
  Timer? _pollingTimer;

  // Variáveis de paginação
  final RxBool _isLoadingMore = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxBool _hasNextPage = true.obs;
  final int _itemsPerPage = 20;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasNextPage => _hasNextPage.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  bool isConfirming(String orderId) => _confirmingOrderId.value == orderId;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  @override
  void onReady() {
    super.onReady();
    // Inicia polling apenas se houver pedidos ativos
    _updatePollingByOrders();
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }

  void _startPolling() {
    if (_pollingTimer != null) return; // já está rodando
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _refreshOrdersSilently();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _orders.clear();
    }
    
    _isLoading.value = true;

    try {
      final result = await _orderRepository.getUserOrdersPaginated(
        page: _currentPage.value,
        limit: _itemsPerPage,
      );
      
      final orders = result['orders'] as List<OrderModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      
      if (refresh) {
        _orders.value = orders;
      } else {
        _orders.addAll(orders);
      }
      
      _currentPage.value = pagination['currentPage'];
      _totalPages.value = pagination['totalPages'];
      _hasNextPage.value = pagination['hasNextPage'];
      
      _updatePollingByOrders();
    } catch (e) {
      // Log do erro, mas não mostrar snackbar aqui pois não temos contexto
      AppLogger.error('❌ [HISTORY] Erro ao carregar histórico de pedidos', e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (_isLoadingMore.value || !_hasNextPage.value) return;
    
    _isLoadingMore.value = true;
    
    try {
      final nextPage = _currentPage.value + 1;
      final result = await _orderRepository.getUserOrdersPaginated(
        page: nextPage,
        limit: _itemsPerPage,
      );
      
      final orders = result['orders'] as List<OrderModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      
      _orders.addAll(orders);
      _currentPage.value = pagination['currentPage'];
      _totalPages.value = pagination['totalPages'];
      _hasNextPage.value = pagination['hasNextPage'];
      
    } catch (e) {
      AppLogger.error('❌ [HISTORY] Erro ao carregar mais pedidos', e);
    } finally {
      _isLoadingMore.value = false;
    }
  }

  Future<void> _refreshOrdersSilently() async {
    try {
      final latest = await _orderRepository.getUserOrders();

      // Se quantidade mudou, substitui tudo
      if (latest.length != _orders.length) {
        _orders.value = latest;
        return;
      }

      final latestById = {for (final o in latest) o.id: o};
      bool changed = false;

      for (var i = 0; i < _orders.length; i++) {
        final current = _orders[i];
        final updated = latestById[current.id];
        if (updated == null) {
          changed = true;
          break;
        }

        if (updated.status != current.status ||
            updated.total != current.total ||
            updated.updatedAt != current.updatedAt) {
          _orders[i] = updated;
          changed = true;
        }
      }

      if (changed) {
        _orders.refresh();
      }

      // Reconfigura polling conforme estado atual
      _updatePollingByOrders();
    } catch (e) {
      // Polling silencioso para não incomodar o usuário
      AppLogger.debug('🔄 [HISTORY] Polling falhou: $e');
    }
  }

  bool _hasActiveOrders(List<OrderModel> list) {
    if (list.isEmpty) return false;
    final activeStatuses = {'pending', 'confirmed', 'preparing', 'delivering'};
    return list.any((o) => activeStatuses.contains(o.status.toLowerCase()));
  }

  void _updatePollingByOrders() {
    if (_hasActiveOrders(_orders)) {
      _startPolling();
    } else {
      _stopPolling();
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

  Future<void> confirmOrderReceived(
      String orderId, BuildContext context) async {
    try {
      _confirmingOrderId.value = orderId;
      await _orderRepository.confirmDelivery(orderId);
      
      // Recarregar lista paginada de pedidos
      _loadOrders(refresh: true);
      
      SnackBarUtils.showSuccess(context, 'Entrega confirmada! Obrigado.');
      
      // Voltar para a lista de pedidos se estiver em uma tela de detalhes
      if (Get.currentRoute != '/cliente') {
        Get.back();
      }
    } catch (e) {
      SnackBarUtils.showError(context, 'Não foi possível confirmar: $e');
    } finally {
      _confirmingOrderId.value = '';
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

  void refreshOrders({bool refresh = true}) {
    _loadOrders(refresh: refresh);
  }
}
