class OrderModel {
  final String? id;
  final String? clientId;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String status;
  final String? paymentMethod;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sellerId;
  final String? sellerName;
  final String? sellerEmail;
  final String? sellerPhone;

  OrderModel({
    this.id,
    this.clientId,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.status,
    this.paymentMethod,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.createdAt,
    this.updatedAt,
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.sellerPhone,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id']?.toString(),
        clientId: json['clientId']?.toString(),
        clientName: json['clientName']?.toString(),
        clientEmail: json['clientEmail']?.toString(),
        clientPhone: json['clientPhone']?.toString(),
        items: (json['items'] as List<dynamic>?)
                ?.map((item) => OrderItemModel.fromJson(item))
                .toList() ??
            [],
        subtotal: json['subtotal']?.toDouble() ?? 0.0,
        shipping: json['shipping']?.toDouble() ?? 0.0,
        total: json['total']?.toDouble() ?? 0.0,
        status: json['status']?.toString() ?? 'pending',
        paymentMethod: json['paymentMethod']?.toString(),
        deliveryAddress: json['delivery_address']?.toString(),
        deliveryInstructions: json['deliveryInstructions']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        sellerId: json['sellerId']?.toString(),
        sellerName: json['sellerName']?.toString(),
        sellerEmail: json['sellerEmail']?.toString(),
        sellerPhone: json['sellerPhone']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone,
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'shipping': shipping,
        'total': total,
        'status': status,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'deliveryInstructions': deliveryInstructions,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerEmail': sellerEmail,
        'sellerPhone': sellerPhone,
      };

  OrderModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    List<OrderItemModel>? items,
    double? subtotal,
    double? shipping,
    double? total,
    String? status,
    String? paymentMethod,
    String? deliveryAddress,
    String? deliveryInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sellerId,
    String? sellerName,
    String? sellerEmail,
    String? sellerPhone,
  }) {
    return OrderModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      sellerPhone: sellerPhone ?? this.sellerPhone,
    );
  }
}

class OrderItemModel {
  final String? productId;
  final String? productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double total;
  final bool? isSoldByWeight;
  final double? pricePerKg;

  OrderItemModel({
    this.productId,
    this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.total,
    this.isSoldByWeight,
    this.pricePerKg,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId']?.toString(),
        productName: json['productName']?.toString(),
        productImage: json['productImage']?.toString(),
        price: json['price']?.toDouble() ?? 0.0,
        quantity: json['quantity'] ?? 0,
        total: json['total']?.toDouble() ?? 0.0,
        isSoldByWeight: json['isSoldByWeight'],
        pricePerKg: json['pricePerKg']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'price': price,
        'quantity': quantity,
        'total': total,
        'isSoldByWeight': isSoldByWeight,
        'pricePerKg': pricePerKg,
      };
}

class CheckoutData {
  final String? clientId;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final String? paymentMethod;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shipping;
  final double total;

  CheckoutData({
    this.clientId,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone,
        'deliveryAddress': deliveryAddress,
        'deliveryInstructions': deliveryInstructions,
        'paymentMethod': paymentMethod,
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'shipping': shipping,
        'total': total,
      };
}
