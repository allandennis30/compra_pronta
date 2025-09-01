import '../../../core/models/user_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final AddressModel deliveryAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    required this.deliveryAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        userId:
            json['clientId'] ?? json['userId'], // Suporte para ambos os campos
        items: (json['items'] as List)
            .map((item) => OrderItemModel.fromJson(item))
            .toList(),
        subtotal: json['subtotal'].toDouble(),
        deliveryFee: json['shipping']?.toDouble() ??
            json['deliveryFee']?.toDouble() ??
            0.0,
        total: json['total'].toDouble(),
        status: json['status'],
        createdAt: DateTime.parse(json['createdAt']),
        deliveredAt: json['actualDeliveryTime'] != null
            ? DateTime.parse(json['actualDeliveryTime'])
            : json['deliveredAt'] != null
                ? DateTime.parse(json['deliveredAt'])
                : null,
        deliveryAddress: AddressModel.fromJson(json['deliveryAddress']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': userId, // Alinhado com a estrutura da tabela
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'shipping': deliveryFee, // Alinhado com a estrutura da tabela
        'total': total,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'actualDeliveryTime': deliveredAt
            ?.toIso8601String(), // Alinhado com a estrutura da tabela
        'deliveryAddress': deliveryAddress.toJson(),
      };

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'delivering':
        return 'Em Entrega';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId'],
        productName: json['productName'],
        price: json['price'].toDouble(),
        quantity: json['quantity'],
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };

  double get total => price * quantity;
}
