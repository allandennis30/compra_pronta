import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_constants.dart';
import '../../auth/repositories/auth_repository.dart';

class DeliveryRepository {
  final AuthRepository _authRepository = AuthRepositoryImpl();

  /// Registrar usuário como entregador
  Future<Map<String, dynamic>> registerAsDelivery(String sellerId) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final baseUrl = await AppConstants.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/delivery/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'sellerId': sellerId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao registrar como entregador');
      }
    } catch (e) {
      throw Exception('Erro ao registrar como entregador: $e');
    }
  }

  /// Buscar lojas onde o usuário é entregador
  Future<List<Map<String, dynamic>>> getDeliveryStores() async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final baseUrl = await AppConstants.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/api/delivery/stores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao buscar lojas de entrega');
      }
    } catch (e) {
      throw Exception('Erro ao buscar lojas de entrega: $e');
    }
  }

  /// Buscar pedidos para entrega com paginação
  Future<Map<String, dynamic>> getDeliveryOrders({
    String? storeId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final baseUrl = await AppConstants.baseUrl;
      String url = '$baseUrl/api/delivery/orders';
      final queryParams = <String>[];
      if (storeId != null) queryParams.add('storeId=$storeId');
      if (status != null) queryParams.add('status=$status');
      queryParams.add('page=$page');
      queryParams.add('limit=$limit');
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      // Debug: log da requisição
      print('🌐 [DELIVERY_REPOSITORY] Fazendo requisição:');
      print('   - URL: $url');
      print('   - Token presente: ${token.isNotEmpty}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Debug: log da resposta
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orders = List<Map<String, dynamic>>.from(data['data'] ?? []);
        print('   - Pedidos retornados: ${orders.length}');
        
        return {
          'orders': orders,
          'currentPage': data['currentPage'] ?? page,
          'totalPages': data['totalPages'] ?? 1,
          'totalItems': data['totalItems'] ?? orders.length,
          'hasNextPage': data['hasNextPage'] ?? false,
        };
      } else {
        final error = json.decode(response.body);
        print('❌ [DELIVERY_REPOSITORY] Erro na resposta: ${error['message']}');
        throw Exception(error['message'] ?? 'Erro ao buscar pedidos para entrega');
      }
    } catch (e) {
      print('❌ [DELIVERY_REPOSITORY] Exceção: $e');
      throw Exception('Erro ao buscar pedidos para entrega: $e');
    }
  }

  /// Confirmar entrega de pedido
  Future<Map<String, dynamic>> confirmDelivery(
    String orderId,
    String confirmationCode,
    {String? notes}
  ) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      // Obter dados do usuário atual
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      final baseUrl = await AppConstants.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/$orderId/confirm-delivery-by-deliverer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'delivererId': user.id,
          'hash': confirmationCode,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao confirmar entrega');
      }
    } catch (e) {
      throw Exception('Erro ao confirmar entrega: $e');
    }
  }

  /// Buscar pedidos para entrega (método de compatibilidade)
  Future<List<Map<String, dynamic>>> getDeliveryOrdersList({
    String? storeId,
    String? status,
  }) async {
    final result = await getDeliveryOrders(
      storeId: storeId,
      status: status,
      page: 1,
      limit: 1000, // Buscar todos os pedidos para compatibilidade
    );
    return List<Map<String, dynamic>>.from(result['orders'] ?? []);
  }

  /// Buscar estatísticas do entregador
  Future<Map<String, dynamic>> getDeliveryStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final baseUrl = await AppConstants.baseUrl;
      String url = '$baseUrl/api/delivery/stats';
      final queryParams = <String>[];
      if (dateFrom != null) queryParams.add('dateFrom=$dateFrom');
      if (dateTo != null) queryParams.add('dateTo=$dateTo');
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao buscar estatísticas de entrega');
      }
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas de entrega: $e');
    }
  }

  /// Atualizar status do pedido
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
    {String? notes}
  ) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final baseUrl = await AppConstants.baseUrl;
      final response = await http.patch(
        Uri.parse('$baseUrl/api/delivery/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': status,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao atualizar status do pedido');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status do pedido: $e');
    }
  }
}