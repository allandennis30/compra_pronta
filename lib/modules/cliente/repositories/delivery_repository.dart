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

  /// Buscar pedidos para entrega
  Future<List<Map<String, dynamic>>> getDeliveryOrders({
    String? storeId,
    String? status,
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
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao buscar pedidos para entrega');
      }
    } catch (e) {
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

      final baseUrl = await AppConstants.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/delivery/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'orderId': orderId,
          'confirmationCode': confirmationCode,
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