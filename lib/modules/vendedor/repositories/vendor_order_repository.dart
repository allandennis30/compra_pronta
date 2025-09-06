import 'package:get/get.dart';
import '../../../core/models/order_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';

abstract class VendorOrderRepository {
  Future<List<OrderModel>> getVendorOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, String status);
}

class VendorOrderRepositoryImpl implements VendorOrderRepository {
  @override
  Future<List<OrderModel>> getVendorOrders() async {
    try {
      // Obter usuário atual
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        AppLogger.error('Vendedor não autenticado');
        return [];
      }

      // Buscar pedidos da API
      try {
        final apiService = Get.find<ApiService>();
        final response = await apiService.get('/orders/seller');

        if (response['success'] == true && response['orders'] != null) {
          final ordersData = response['orders'] as List<dynamic>;
          final orders = ordersData
              .map((json) {
                try {
                  // Converter o formato da API para o formato do modelo
                  final convertedJson = _convertApiOrderToModel(json);
                  final order = OrderModel.fromJson(convertedJson);
                  return order;
                } catch (e) {
                  return null;
                }
              })
              .where((order) => order != null)
              .cast<OrderModel>()
              .toList();
          return orders;
        } else {
          return [];
        }
      } catch (apiError) {
        return [];
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar pedidos do vendedor', e);
      return [];
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.get('/orders/$orderId');

      if (response['success'] == true && response['order'] != null) {
        final json = response['order'];
        final convertedJson = _convertApiOrderToModel(json);

        return OrderModel.fromJson(convertedJson);
      }

      return null;
    } catch (e) {
      AppLogger.error('Erro ao buscar pedido específico', e);
      return null;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.put('/orders/$orderId/status', {
        'status': status,
      });

      if (response['success'] == true) {
        // Status atualizado com sucesso
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      AppLogger.error('Erro ao atualizar status do pedido', e);
      throw e;
    }
  }

  // Método para converter o formato da API para o formato do modelo
  Map<String, dynamic> _convertApiOrderToModel(Map<String, dynamic> apiOrder) {
    final convertedAddress =
        _convertApiAddressToModel(apiOrder['deliveryAddress'] ?? '');

    return {
      'id': apiOrder['id'] ?? '',
      'userId': apiOrder['clientId'] ?? apiOrder['client_id'] ?? '',
      'clientName': apiOrder['clientName'] ?? null,
      'clientEmail': apiOrder['clientEmail'] ?? null,
      'clientPhone': apiOrder['clientPhone'] ?? null,
      'items': _convertApiItemsToModel(apiOrder['items'] ?? <dynamic>[]),
      'subtotal': (apiOrder['subtotal'] ?? 0).toDouble(),
      'deliveryFee': (apiOrder['shipping'] ?? 0).toDouble(),
      'total': (apiOrder['total'] ?? 0).toDouble(),
      'status': apiOrder['status'] ?? 'pending',
      'paymentMethod': apiOrder['paymentMethod'] ?? null,
      'deliveryInstructions': apiOrder['deliveryInstructions'] ?? null,
      'createdAt': apiOrder['createdAt'] != null
          ? apiOrder['createdAt']
          : apiOrder['created_at'] != null
              ? apiOrder['created_at']
              : null,
      'deliveredAt': apiOrder['actualDeliveryTime'] != null
          ? apiOrder['actualDeliveryTime']
          : apiOrder['actual_delivery_time'] != null
              ? apiOrder['actual_delivery_time']
              : null,
      'updatedAt': apiOrder['updatedAt'] != null ? apiOrder['updatedAt'] : null,
      'deliveryAddress': convertedAddress,
      'estimatedDeliveryTime': apiOrder['estimatedDeliveryTime'] != null
          ? apiOrder['estimatedDeliveryTime']
          : null,
      'notes': apiOrder['notes'] ?? null,
      'sellerId': apiOrder['sellerId'] ?? null,
      'sellerName': apiOrder['sellerName'] ?? null,
    };
  }

  List<Map<String, dynamic>> _convertApiItemsToModel(List<dynamic> apiItems) {
    return apiItems.map((item) {
      return {
        'productId': item['productId'] ?? item['product_id'],
        'productName': item['productName'] ?? item['product_name'],
        'price': (item['price'] ?? 0).toDouble(),
        'quantity': item['quantity'] ?? 1,
        'total': (item['total'] ?? 0).toDouble(),
      };
    }).toList();
  }

  Map<String, dynamic> _convertApiAddressToModel(dynamic addressData) {
    // Se já é um Map, verificar se tem conteúdo válido
    if (addressData is Map<String, dynamic>) {
      // Verificar se todos os campos estão vazios
      final street = addressData['street'] ?? '';
      final number = addressData['number'] ?? '';
      final complement = addressData['complement'];
      final neighborhood = addressData['neighborhood'] ?? '';
      final city = addressData['city'] ?? '';
      final state = addressData['state'] ?? '';
      final zipCode = addressData['zipCode'] ?? '';

      // Se todos os campos estão vazios, usar fallback
      if (street.isEmpty &&
          number.isEmpty &&
          neighborhood.isEmpty &&
          city.isEmpty &&
          state.isEmpty &&
          zipCode.isEmpty) {
        return {
          'street': 'Endereço não informado',
          'number': 0,
          'complement': null,
          'neighborhood': '',
          'city': '',
          'state': '',
          'zipCode': '',
        };
      }

      // Se pelo menos um campo tem valor, retornar o Map
      return addressData;
    }

    // Se é uma string, processar normalmente
    if (addressData is String) {
      final addressText = addressData;

      if (addressText.isEmpty || addressText.trim().isEmpty) {
        return {
          'street': 'Endereço não informado',
          'number': 0,
          'complement': null,
          'neighborhood': '',
          'city': '',
          'state': '',
          'zipCode': '',
        };
      }

      // Verificar se o endereço é o padrão problemático
      if (addressText.contains('Endereço não informado') &&
          addressText.contains(' - ')) {
        return {
          'street': 'Endereço não informado',
          'number': 0,
          'complement': null,
          'neighborhood': '',
          'city': '',
          'state': '',
          'zipCode': '',
        };
      }

      // Tentar extrair componentes do endereço
      final parts = addressText.split(',').map((part) => part.trim()).toList();

      if (parts.length >= 7) {
        // Padrão: "Rua, Número, Bairro, Cidade, Estado, CEP, Complemento"
        return {
          'street': parts[0],
          'number': int.tryParse(parts[1]) ?? 0,
          'complement': parts[6], // Complemento é a 7ª parte
          'neighborhood': parts[2],
          'city': parts[3],
          'state': parts[4],
          'zipCode': parts[5],
        };
      } else if (parts.length >= 6) {
        // Padrão: "Rua, Número, Bairro, Cidade, Estado, CEP"
        return {
          'street': parts[0],
          'number': int.tryParse(parts[1]) ?? 0,
          'complement': null,
          'neighborhood': parts[2],
          'city': parts[3],
          'state': parts[4],
          'zipCode': parts[5],
        };
      } else if (parts.length >= 4) {
        // Padrão alternativo: "Rua, Bairro, Cidade, Estado"
        return {
          'street': parts[0],
          'number': 0,
          'complement': null,
          'neighborhood': parts[1],
          'city': parts[2],
          'state': parts[3],
          'zipCode': parts.length > 4 ? parts[4] : '',
        };
      } else {
        // Se não conseguir extrair, usar a string completa como rua
        return {
          'street': addressText,
          'number': 0,
          'complement': null,
          'neighborhood': '',
          'city': '',
          'state': '',
          'zipCode': '',
        };
      }
    }

    // Fallback para qualquer outro tipo
    return {
      'street': 'Endereço não informado',
      'number': 0,
      'complement': null,
      'neighborhood': '',
      'city': '',
      'state': '',
      'zipCode': '',
    };
  }
}
