import 'package:compra_pronta/core/models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/repositories/base_repository.dart';
import '../../../core/models/order_model.dart';
import '../../../constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/api_service.dart';
import 'package:get/get.dart';

abstract class OrderRepository extends BaseRepository<OrderModel> {
  Future<List<OrderModel>> getUserOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<void> updateOrderStatus(String orderId, String status);
}

class OrderRepositoryImpl implements OrderRepository {
  final GetStorage _storage = GetStorage();

  @override
  Future<List<OrderModel>> getAll() async {
    return getUserOrders();
  }

  @override
  Future<OrderModel?> getById(String id) async {
    return getOrderById(id);
  }

  @override
  Future<OrderModel> create(OrderModel item) async {
    return createOrder(item);
  }

  @override
  Future<OrderModel> update(OrderModel item) async {
    // Simular atualização
    await Future.delayed(Duration(milliseconds: 300));
    return item;
  }

  @override
  Future<bool> delete(String id) async {
    // Simular exclusão
    await Future.delayed(Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<List<OrderModel>> search(String query) async {
    final orders = await getUserOrders();
    return orders
        .where((order) =>
            order.id.toLowerCase().contains(query.toLowerCase()) ||
            order.status.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<OrderModel>> getUserOrders() async {
    try {
      // Obter usuário atual
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        AppLogger.error('Usuário não autenticado');
        return [];
      }

      // Tentar buscar da API real primeiro
      try {
        final apiService = Get.find<ApiService>();
        AppLogger.info('📡 [ORDER] Chamando API /orders...');
        final response = await apiService.get('/orders');
        AppLogger.info('📡 [ORDER] API chamada com sucesso');

        AppLogger.info('📡 [ORDER] Resposta da API de pedidos:');
        AppLogger.info('   - Success: ${response['success']}');
        AppLogger.info('   - Orders count: ${response['orders']?.length ?? 0}');

        if (response['success'] == true && response['orders'] != null) {
          final ordersData = response['orders'] as List<dynamic>;
          AppLogger.info(
              '📋 [ORDER] Processando ${ordersData.length} pedidos da API');

          // Log dos dados brutos da API
          AppLogger.info('📄 [ORDER] Dados brutos da API:');
          AppLogger.info('📄 [ORDER] Response completa: $response');
          AppLogger.info('📄 [ORDER] Orders data: $ordersData');

          for (int i = 0; i < ordersData.length; i++) {
            final json = ordersData[i];
            AppLogger.info('📦 [ORDER] Pedido ${i + 1} (JSON):');
            AppLogger.info('   - ID: ${json['id']}');
            AppLogger.info('   - Status: ${json['status']}');
            AppLogger.info('   - Total: ${json['total']}');
            AppLogger.info('   - Itens: ${json['items']}');
            AppLogger.info('   - Itens é List: ${json['items'] is List}');
            AppLogger.info('   - Itens é null: ${json['items'] == null}');
            AppLogger.info('   - Itens type: ${json['items']?.runtimeType}');
            AppLogger.info('   - Itens toString: ${json['items'].toString()}');

            if (json['items'] is List) {
              final items = json['items'] as List;
              AppLogger.info('   - Quantidade de itens: ${items.length}');
              for (int j = 0; j < items.length; j++) {
                final item = items[j];
                AppLogger.info('     ${j + 1}. ${item}');
              }
            } else if (json['items'] != null) {
              AppLogger.info('   - Itens não é List, é: ${json['items']}');
            } else {
              AppLogger.warning('   - ⚠️ ITENS É NULL OU VAZIO!');
            }
          }

          final orders = ordersData
              .map((json) {
                try {
                  AppLogger.info(
                      '🔄 [ORDER] Convertendo pedido: ${json['id']}');
                  final order = OrderModel.fromJson(json);
                  AppLogger.info(
                      '✅ [ORDER] Pedido ${json['id']} convertido com ${order.items.length} itens');
                  AppLogger.info('✅ [ORDER] Itens do pedido: ${order.items}');
                  return order;
                } catch (e) {
                  AppLogger.error(
                      '❌ [ORDER] Erro ao converter pedido ${json['id']}:', e);
                  return null;
                }
              })
              .where((order) => order != null)
              .where((order) => order!.userId == currentUser.id)
              .cast<OrderModel>()
              .toList();

          AppLogger.info(
              '✅ [ORDER] ${orders.length} pedidos processados com sucesso');
          AppLogger.info('✅ [ORDER] Pedidos finais: $orders');
          AppLogger.info('✅ [ORDER] Retornando pedidos para o controller...');
          return orders;
        }
      } catch (apiError) {
        AppLogger.warning(
            '❌ [ORDER] Erro ao buscar pedidos da API, usando dados locais: $apiError');
      }

      // Fallback para dados locais
      final ordersData =
          _storage.read(AppConstants.ordersKey) as List<dynamic>?;
      if (ordersData != null) {
        final allOrders =
            ordersData.map((json) => OrderModel.fromJson(json)).toList();
        return allOrders
            .where((order) => order.userId == currentUser.id)
            .toList();
      }

      // Retornar dados mock apenas se for o usuário cliente correto
      if (currentUser.id == 'user_cliente_001') {
        return _getMockOrders();
      }

      return [];
    } catch (e) {
      AppLogger.error('Erro ao carregar pedidos do usuário', e);
      return [];
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final orders = await getUserOrders();
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    AppLogger.info('🛒 [ORDER] Criando pedido local: ${order.id}');

    // Simular criação na API
    await Future.delayed(Duration(milliseconds: 300));

    // Salvar no storage local
    final orders = await getUserOrders();
    orders.add(order);
    await _storage.write(
        AppConstants.ordersKey, orders.map((o) => o.toJson()).toList());

    AppLogger.info('✅ [ORDER] Pedido salvo localmente: ${order.id}');
    return order;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    final orders = await getUserOrders();
    final orderIndex = orders.indexWhere((order) => order.id == orderId);

    if (orderIndex != -1) {
      final updatedOrder = OrderModel(
        id: orders[orderIndex].id,
        userId: orders[orderIndex].userId,
        items: orders[orderIndex].items,
        subtotal: orders[orderIndex].subtotal,
        deliveryFee: orders[orderIndex].deliveryFee,
        total: orders[orderIndex].total,
        status: status,
        createdAt: orders[orderIndex].createdAt,
        deliveredAt: status == 'delivered'
            ? DateTime.now()
            : orders[orderIndex].deliveredAt,
        deliveryAddress: orders[orderIndex].deliveryAddress,
      );

      orders[orderIndex] = updatedOrder;
      await _storage.write(
          AppConstants.ordersKey, orders.map((o) => o.toJson()).toList());
    }
  }

  List<OrderModel> _getMockOrders() {
    // Endereço padrão para dados mock
    final defaultAddress = AddressModel(
      street: 'Rua das Flores, 123',
      number: '123',
      complement: 'Apto 45',
      neighborhood: 'Centro',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01234-567',
    );

    return [
      OrderModel(
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
            quantity: 1,
          ),
        ],
        subtotal: 22.30,
        deliveryFee: 5.00,
        total: 27.30,
        status: 'delivered',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        deliveredAt: DateTime.now().subtract(const Duration(days: 6)),
        deliveryAddress: defaultAddress,
      ),
      OrderModel(
        id: 'order_002',
        userId: 'user_cliente_001',
        items: [
          OrderItemModel(
            productId: 'prod_003',
            productName: 'Leite Integral',
            price: 6.90,
            quantity: 1,
          ),
        ],
        subtotal: 6.90,
        deliveryFee: 5.00,
        total: 11.90,
        status: 'delivering',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        deliveryAddress: defaultAddress,
      ),
    ];
  }
}
