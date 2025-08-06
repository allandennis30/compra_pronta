import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/logger.dart';

class VendorOrderListController extends GetxController {
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<OrderModel> _filteredOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedStatus = 'all'.obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _isSearching = false.obs;

  List<OrderModel> get orders => _filteredOrders;
  bool get isLoading => _isLoading.value;
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
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simular busca de pedidos (substituir por repository real)
      await Future.delayed(Duration(milliseconds: 800));
      
      final mockOrders = _getMockOrders();
      _orders.assignAll(mockOrders);
      _applyFilters();
    } catch (e) {
      _errorMessage.value = 'Erro ao carregar pedidos: $e';
      AppLogger.error('Erro ao carregar pedidos', e);
    } finally {
      _isLoading.value = false;
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
      filtered = filtered.where((order) => order.status == _selectedStatus.value).toList();
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
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'delivering':
        return Colors.indigo;
      case 'delivered':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void navigateToOrderDetail(String orderId) {
    Get.toNamed('/vendor/pedido/$orderId');
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }

  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: 'ORD_001',
        userId: 'USER_001',
        items: [],
        subtotal: 45.90,
        deliveryFee: 5.00,
        total: 50.90,
        status: 'pending',
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
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
      OrderModel(
        id: 'ORD_002',
        userId: 'USER_002',
        items: [],
        subtotal: 78.50,
        deliveryFee: 5.00,
        total: 83.50,
        status: 'confirmed',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        deliveryAddress: AddressModel(
          street: 'Av. Paulista',
          number: '1000',
          complement: '',
          neighborhood: 'Bela Vista',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01310-100',
        ),
      ),
      OrderModel(
        id: 'ORD_003',
        userId: 'USER_003',
        items: [],
        subtotal: 120.00,
        deliveryFee: 8.00,
        total: 128.00,
        status: 'preparing',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        deliveryAddress: AddressModel(
          street: 'Rua Augusta',
          number: '500',
          complement: 'Casa',
          neighborhood: 'Consolação',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01305-000',
        ),
      ),
      OrderModel(
        id: 'ORD_004',
        userId: 'USER_004',
        items: [],
        subtotal: 95.75,
        deliveryFee: 5.00,
        total: 100.75,
        status: 'ready',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        deliveryAddress: AddressModel(
          street: 'Rua Oscar Freire',
          number: '200',
          complement: 'Loja 1',
          neighborhood: 'Jardins',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01426-000',
        ),
      ),
      OrderModel(
        id: 'ORD_005',
        userId: 'USER_005',
        items: [],
        subtotal: 67.30,
        deliveryFee: 5.00,
        total: 72.30,
        status: 'delivering',
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
        deliveryAddress: AddressModel(
          street: 'Rua da Consolação',
          number: '800',
          complement: 'Apto 12',
          neighborhood: 'Consolação',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01302-000',
        ),
      ),
      OrderModel(
        id: 'ORD_006',
        userId: 'USER_006',
        items: [],
        subtotal: 156.80,
        deliveryFee: 8.00,
        total: 164.80,
        status: 'delivered',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        deliveredAt: DateTime.now().subtract(Duration(hours: 20)),
        deliveryAddress: AddressModel(
          street: 'Av. Faria Lima',
          number: '1500',
          complement: 'Sala 10',
          neighborhood: 'Itaim Bibi',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01452-000',
        ),
      ),
    ];
  }
}