import 'user_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final String? paymentMethod;
  final String? deliveryInstructions;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? estimatedDeliveryTime;
  final DateTime? updatedAt;
  final AddressModel deliveryAddress;
  final String? notes;
  final String? sellerId;
  final String? sellerName;

  OrderModel({
    required this.id,
    required this.userId,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    this.paymentMethod,
    this.deliveryInstructions,
    required this.createdAt,
    this.deliveredAt,
    this.estimatedDeliveryTime,
    this.updatedAt,
    required this.deliveryAddress,
    this.notes,
    this.sellerId,
    this.sellerName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> items = <OrderItemModel>[];

    if (json['items'] is List) {
      final itemsList = json['items'] as List;
      items = itemsList.map((item) {
        return OrderItemModel.fromJson(item);
      }).toList();
    }

    return OrderModel(
      id: json['id'],
      userId:
          json['clientId'] ?? json['userId'], // Suporte para ambos os campos
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      clientPhone: json['clientPhone'],
      items: items,
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: json['shipping']?.toDouble() ??
          json['deliveryFee']?.toDouble() ??
          0.0, // Suporte para ambos os campos
      total: json['total']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      deliveryInstructions: json['deliveryInstructions'],
      createdAt: DateTime.parse(json['createdAt']),
      deliveredAt: json['actualDeliveryTime'] != null
          ? DateTime.parse(json['actualDeliveryTime'])
          : json['deliveredAt'] != null
              ? DateTime.parse(json['deliveredAt'])
              : null,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'])
          : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deliveryAddress: _parseDeliveryAddress(json['deliveryAddress']),
      notes: json['notes'],
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone,
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'status': status,
        'paymentMethod': paymentMethod,
        'deliveryInstructions': deliveryInstructions,
        'createdAt': createdAt.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'deliveryAddress': deliveryAddress.toJson(),
        'notes': notes,
        'sellerId': sellerId,
        'sellerName': sellerName,
      };

  static AddressModel _parseDeliveryAddress(dynamic addressData) {
    if (addressData is Map<String, dynamic>) {
      // Se já é um objeto estruturado
      // Verificar se o Map tem os campos corretos
      final street = addressData['street'] ?? '';
      final number = addressData['number'] ?? '';
      final neighborhood = addressData['neighborhood'] ?? '';
      final city = addressData['city'] ?? '';
      final state = addressData['state'] ?? '';
      final zipCode = addressData['zipCode'] ?? '';

      // Verificar se todos os campos estão vazios (caso problemático)
      if (street.isEmpty &&
          number.isEmpty &&
          neighborhood.isEmpty &&
          city.isEmpty &&
          state.isEmpty &&
          zipCode.isEmpty) {
        return AddressModel(
          street: 'Endereço não informado',
          number: 0,
          complement: null,
          neighborhood: '',
          city: '',
          state: '',
          zipCode: '',
        );
      }

      // Se pelo menos um campo tem valor, usar o Map
      return AddressModel.fromJson(addressData);
    } else if (addressData is String) {
      // Se é uma string, tentar extrair os componentes
      final addressString = addressData.trim();

      // Verificar se é o padrão problemático
      if (addressString.contains('Endereço não informado') &&
          addressString.contains(' - ')) {
        return AddressModel(
          street: 'Endereço não informado',
          number: 0,
          complement: null,
          neighborhood: '',
          city: '',
          state: '',
          zipCode: '',
        );
      }

      // Padrão: "Rua, Número, Bairro, Cidade, Estado, CEP"
      final parts = addressString.split(',');

      if (parts.length >= 6) {
        final result = AddressModel(
          street: parts[0].trim(),
          number: int.parse(parts[1].trim()),
          complement: null,
          neighborhood: parts[2].trim(),
          city: parts[3].trim(),
          state: parts[4].trim(),
          zipCode: parts[5].trim(),
        );
        return result;
      } else if (parts.length >= 4) {
        // Padrão alternativo: "Rua, Bairro, Cidade, Estado"
        final result = AddressModel(
          street: parts[0].trim(),
          number: 0,
          complement: null,
          neighborhood: parts[1].trim(),
          city: parts[2].trim(),
          state: parts[3].trim(),
          zipCode: parts.length > 4 ? parts[4].trim() : '',
        );
        return result;
      } else {
        // Se não conseguir extrair, usar a string completa como rua
        final result = AddressModel(
          street: addressString,
          number: 0,
          complement: null,
          neighborhood: '',
          city: '',
          state: '',
          zipCode: '',
        );
        return result;
      }
    } else {
      // Fallback para endereço vazio
      return AddressModel(
        street: 'Endereço não informado',
        number: 0,
        complement: null,
        neighborhood: '',
        city: '',
        state: '',
        zipCode: '',
      );
    }
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productId = json['productId'] ?? json['product_id'] ?? '';
    final productName = json['productName'] ?? json['product_name'] ?? '';
    final price = (json['price'] ?? 0.0).toDouble();
    final quantity = json['quantity'] ?? 0;

    return OrderItemModel(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };
}
