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
        AppLogger.info('📡 [VENDOR_ORDER] Chamando API /orders/seller...');

        final response = await apiService.get('/orders/seller');
        AppLogger.info('📡 [VENDOR_ORDER] API chamada com sucesso');

        AppLogger.info('📡 [VENDOR_ORDER] Resposta da API:');
        AppLogger.info('   - Success: ${response['success']}');
        AppLogger.info('   - Orders count: ${response['orders']?.length ?? 0}');

        if (response['success'] == true && response['orders'] != null) {
          final ordersData = response['orders'] as List<dynamic>;
          AppLogger.info(
              '📋 [VENDOR_ORDER] Processando ${ordersData.length} pedidos');

          final orders = ordersData
              .map((json) {
                try {
                  AppLogger.info(
                      '🔄 [VENDOR_ORDER] Convertendo pedido: ${json['id']}');

                  // Converter o formato da API para o formato do modelo
                  final convertedJson = _convertApiOrderToModel(json);
                  final order = OrderModel.fromJson(convertedJson);

                  AppLogger.info(
                      '✅ [VENDOR_ORDER] Pedido ${json['id']} convertido com ${order.items.length} itens');
                  return order;
                } catch (e) {
                  AppLogger.error(
                      '❌ [VENDOR_ORDER] Erro ao converter pedido ${json['id']}:',
                      e);
                  return null;
                }
              })
              .where((order) => order != null)
              .cast<OrderModel>()
              .toList();

          AppLogger.info(
              '✅ [VENDOR_ORDER] ${orders.length} pedidos processados com sucesso');
          return orders;
        } else {
          AppLogger.warning(
              '⚠️ [VENDOR_ORDER] API retornou sucesso false ou orders null');
          return [];
        }
      } catch (apiError) {
        AppLogger.error(
            '❌ [VENDOR_ORDER] Erro ao buscar pedidos da API:', apiError);
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
      AppLogger.info('📡 [VENDOR_ORDER] Buscando pedido específico: $orderId');

      final response = await apiService.get('/orders/$orderId');

      if (response['success'] == true && response['order'] != null) {
        final json = response['order'];
        AppLogger.info('📡 [VENDOR_ORDER] Resposta da API recebida:');
        AppLogger.info('   - deliveryAddress: ${json['deliveryAddress']}');
        AppLogger.info(
            '   - Tipo do deliveryAddress: ${json['deliveryAddress'].runtimeType}');

        final convertedJson = _convertApiOrderToModel(json);
        AppLogger.info('📡 [VENDOR_ORDER] JSON convertido:');
        AppLogger.info(
            '   - deliveryAddress: ${convertedJson['deliveryAddress']}');

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
      AppLogger.info(
          '📡 [VENDOR_ORDER] Atualizando status do pedido: $orderId para $status');

      final response = await apiService.put('/orders/$orderId/status', {
        'status': status,
      });

      if (response['success'] == true) {
        AppLogger.info('✅ [VENDOR_ORDER] Status atualizado com sucesso');
      } else {
        AppLogger.error(
            '❌ [VENDOR_ORDER] Erro ao atualizar status: ${response['message']}');
        throw Exception(response['message']);
      }
    } catch (e) {
      AppLogger.error('Erro ao atualizar status do pedido', e);
      throw e;
    }
  }

  // Método para converter o formato da API para o formato do modelo
  Map<String, dynamic> _convertApiOrderToModel(Map<String, dynamic> apiOrder) {
    AppLogger.info('🔄 [VENDOR_ORDER] _convertApiOrderToModel chamado');
    AppLogger.info(
        '🔄 [VENDOR_ORDER] deliveryAddress da API: ${apiOrder['deliveryAddress']}');
    AppLogger.info(
        '🔄 [VENDOR_ORDER] Tipo do deliveryAddress: ${apiOrder['deliveryAddress'].runtimeType}');

    final convertedAddress =
        _convertApiAddressToModel(apiOrder['deliveryAddress'] ?? '');
    AppLogger.info('🔄 [VENDOR_ORDER] Endereço convertido: $convertedAddress');

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
    AppLogger.info('🔄 [VENDOR_ORDER] Convertendo ${apiItems.length} itens');
    return apiItems.map((item) {
      final convertedItem = {
        'productId': item['productId'] ?? item['product_id'],
        'productName': item['productName'] ?? item['product_name'],
        'price': (item['price'] ?? 0).toDouble(),
        'quantity': item['quantity'] ?? 1,
        'total': (item['total'] ?? 0).toDouble(),
      };
      AppLogger.info(
          '🔄 [VENDOR_ORDER] Item convertido: ${convertedItem['productName']}');
      return convertedItem;
    }).toList();
  }

  Map<String, dynamic> _convertApiAddressToModel(dynamic addressData) {
    // Converter texto do endereço para o formato do modelo
    AppLogger.info('🔄 [VENDOR_ORDER] Convertendo endereço: $addressData');
    AppLogger.info(
        '🔄 [VENDOR_ORDER] Tipo do addressData: ${addressData.runtimeType}');

    // Se já é um Map, verificar se tem conteúdo válido
    if (addressData is Map<String, dynamic>) {
      AppLogger.info(
          '🔄 [VENDOR_ORDER] AddressData já é Map, verificando conteúdo');

      // Verificar se todos os campos estão vazios
      final street = addressData['street'] ?? '';
      final number = addressData['number'] ?? '';
      final complement = addressData['complement'];
      final neighborhood = addressData['neighborhood'] ?? '';
      final city = addressData['city'] ?? '';
      final state = addressData['state'] ?? '';
      final zipCode = addressData['zipCode'] ?? '';

      AppLogger.info('🔄 [VENDOR_ORDER] Campos do Map:');
      AppLogger.info('   - street: "$street"');
      AppLogger.info('   - number: "$number"');
      AppLogger.info('   - complement: "$complement"');
      AppLogger.info('   - neighborhood: "$neighborhood"');
      AppLogger.info('   - city: "$city"');
      AppLogger.info('   - state: "$state"');
      AppLogger.info('   - zipCode: "$zipCode"');

      // Se todos os campos estão vazios, usar fallback
      if (street.isEmpty &&
          number.isEmpty &&
          neighborhood.isEmpty &&
          city.isEmpty &&
          state.isEmpty &&
          zipCode.isEmpty) {
        AppLogger.warning(
            '⚠️ [VENDOR_ORDER] Todos os campos do Map estão vazios, usando fallback');
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
      AppLogger.info(
          '🔄 [VENDOR_ORDER] Map tem conteúdo válido, retornando diretamente');
      return addressData;
    }

    // Se é uma string, processar normalmente
    if (addressData is String) {
      final addressText = addressData;
      AppLogger.info(
          '🔄 [VENDOR_ORDER] Comprimento do addressText: ${addressText.length}');

      if (addressText.isEmpty || addressText.trim().isEmpty) {
        AppLogger.info('🔄 [VENDOR_ORDER] Endereço vazio, retornando fallback');
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
        AppLogger.warning(
            '⚠️ [VENDOR_ORDER] Endereço problemático detectado, usando fallback');
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
      AppLogger.info('🔄 [VENDOR_ORDER] Partes do endereço: $parts');
      AppLogger.info('🔄 [VENDOR_ORDER] Número de partes: ${parts.length}');

      if (parts.length >= 7) {
        // Padrão: "Rua, Número, Bairro, Cidade, Estado, CEP, Complemento"
        final result = {
          'street': parts[0],
          'number': int.tryParse(parts[1]) ?? 0,
          'complement': parts[6], // Complemento é a 7ª parte
          'neighborhood': parts[2],
          'city': parts[3],
          'state': parts[4],
          'zipCode': parts[5],
        };
        AppLogger.info(
            '🔄 [VENDOR_ORDER] Endereço convertido (7+ partes): $result');
        return result;
      } else if (parts.length >= 6) {
        // Padrão: "Rua, Número, Bairro, Cidade, Estado, CEP"
        final result = {
          'street': parts[0],
          'number': int.tryParse(parts[1]) ?? 0,
          'complement': null,
          'neighborhood': parts[2],
          'city': parts[3],
          'state': parts[4],
          'zipCode': parts[5],
        };
        AppLogger.info(
            '🔄 [VENDOR_ORDER] Endereço convertido (6+ partes): $result');
        return result;
      } else if (parts.length >= 4) {
        // Padrão alternativo: "Rua, Bairro, Cidade, Estado"
        final result = {
          'street': parts[0],
          'number': 0,
          'complement': null,
          'neighborhood': parts[1],
          'city': parts[2],
          'state': parts[3],
          'zipCode': parts.length > 4 ? parts[4] : '',
        };
        AppLogger.info(
            '🔄 [VENDOR_ORDER] Endereço convertido (4+ partes): $result');
        return result;
      } else {
        // Se não conseguir extrair, usar a string completa como rua
        final result = {
          'street': addressText,
          'number': 0,
          'complement': null,
          'neighborhood': '',
          'city': '',
          'state': '',
          'zipCode': '',
        };
        AppLogger.info(
            '🔄 [VENDOR_ORDER] Endereço convertido (fallback): $result');
        return result;
      }
    }

    // Fallback para qualquer outro tipo
    AppLogger.warning(
        '⚠️ [VENDOR_ORDER] Tipo de endereço não reconhecido, usando fallback');
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
