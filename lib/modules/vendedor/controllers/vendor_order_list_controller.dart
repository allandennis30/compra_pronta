import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../core/models/order_model.dart';
import '../../../core/utils/logger.dart';
import '../repositories/vendor_order_repository.dart';

class VendorOrderListController extends GetxController {
  late final VendorOrderRepository _repository;
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<OrderModel> _filteredOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMorePages = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedStatus = 'all'.obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _isSearching = false.obs;
  final ScrollController scrollController = ScrollController();

  List<OrderModel> get orders => _filteredOrders;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMorePages => _hasMorePages.value;
  int get currentPage => _currentPage.value;
  String get errorMessage => _errorMessage.value;
  String get selectedStatus => _selectedStatus.value;
  String get searchQuery => _searchQuery.value;
  bool get isSearching => _isSearching.value;

  final List<String> availableStatuses = [
    'all',
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
    _setupScrollController();
    loadOrders();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _stopAutoRefresh();
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore.value && _hasMorePages.value) {
          loadMoreOrders();
        }
      }
    });
  }

  Timer? _autoRefreshTimer;

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _refreshOrdersSilently();
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<void> loadOrders({bool refresh = false}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      if (refresh) {
        _currentPage.value = 1;
        _hasMorePages.value = true;
        _orders.clear();
      }

      final orders = await _repository.getVendorOrdersPaginated(
        page: _currentPage.value,
        limit: 20,
      );
      
      if (refresh) {
        _orders.assignAll(orders);
      } else {
        _orders.addAll(orders);
      }
      
      // Se retornou menos que o limite, não há mais páginas
      if (orders.length < 20) {
        _hasMorePages.value = false;
      } else {
        // Se retornou exatamente o limite, pode haver mais páginas
        _hasMorePages.value = true;
      }
      
      _applyFilters();
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar pedidos: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (_isLoadingMore.value || !_hasMorePages.value) return;
    
    try {
      _isLoadingMore.value = true;
      _currentPage.value++;
      
      final orders = await _repository.getVendorOrdersPaginated(
        page: _currentPage.value,
        limit: 20,
      );
      
      _orders.addAll(orders);
      
      // Se retornou menos que o limite, não há mais páginas
      if (orders.length < 20) {
        _hasMorePages.value = false;
      }
      
      _applyFilters();
    } catch (e) {
      AppLogger.error('Erro ao carregar mais pedidos', e);
      _currentPage.value--; // Reverter página em caso de erro
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void filterByStatus(String status) {
    _selectedStatus.value = status;
    _applyFilters();
  }

  void searchOrders(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void toggleSearch() {
    _isSearching.value = !_isSearching.value;
    if (!_isSearching.value) {
      _searchQuery.value = '';
      _applyFilters();
    }
  }

  void _applyFilters() {
    var filtered = _orders.toList();

    // Filtrar por status
    if (_selectedStatus.value != 'all') {
      filtered = filtered
          .where((order) => order.status == _selectedStatus.value)
          .toList();
    }

    // Filtrar por busca
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((order) {
        return order.id.toLowerCase().contains(query) ||
            order.status.toLowerCase().contains(query);
      }).toList();
    }

    // Ordenar por data (mais recentes primeiro)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _filteredOrders.assignAll(filtered);
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
        return 'Entregando';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      case 'all':
        return 'Todos';
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
      case 'ready_for_pickup':
        return const Color(0xFF388E3C); // Dark Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  void navigateToOrderDetail(String orderId) {
    try {
      Get.toNamed('/vendor/pedido/$orderId');
    } catch (e) {
      AppLogger.error('Erro ao navegar para detalhes do pedido', e);
      Get.snackbar(
        'Erro',
        'Erro ao abrir detalhes do pedido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Atualiza um pedido específico na lista quando seu status for alterado
  void updateOrderInList(OrderModel updatedOrder) {
    try {
      // Encontrar o índice do pedido na lista
      final index = _orders.indexWhere((order) => order.id == updatedOrder.id);

      if (index != -1) {
        // Atualizar o pedido na lista
        _orders[index] = updatedOrder;

        // Reaplicar filtros para atualizar a lista filtrada
        _applyFilters();

        AppLogger.info(
            '✅ [VENDOR_ORDER_LIST] Pedido ${updatedOrder.id} atualizado na lista');
      } else {
        AppLogger.warning(
            '⚠️ [VENDOR_ORDER_LIST] Pedido ${updatedOrder.id} não encontrado na lista');
      }
    } catch (e) {
      AppLogger.error(
          '❌ [VENDOR_ORDER_LIST] Erro ao atualizar pedido na lista', e);
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }

  Future<void> _refreshOrdersSilently() async {
    try {
      final latest = await _repository.getVendorOrders();

      if (latest.isEmpty) {
        if (_orders.isNotEmpty) {
          _orders.clear();
          _applyFilters();
        }
        return;
      }

      // Se tamanho mudou, substitui por completo
      if (latest.length != _orders.length) {
        _orders.assignAll(latest);
        _applyFilters();
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
        _applyFilters();
      }
    } catch (e) {
      // Refresh silencioso falhou
    }
  }
}
