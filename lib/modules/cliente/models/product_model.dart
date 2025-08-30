class ProductModel {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? imageUrl;
  final String? category;
  final String? barcode;
  final int? stock;
  final bool? isAvailable;
  final double? rating;
  final int? reviewCount;
  final bool? isSoldByWeight;
  final double? pricePerKg;
  // Campos do vendedor
  final String? sellerId;
  final String? sellerName;
  final String? sellerEmail;
  final String? sellerPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.category,
    this.barcode,
    this.stock,
    this.isAvailable,
    this.rating,
    this.reviewCount,
    this.isSoldByWeight,
    this.pricePerKg,
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.sellerPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        description: json['description']?.toString(),
        price: json['price']?.toDouble(),
        imageUrl: json['imageUrl']?.toString(),
        category: json['category']?.toString(),
        barcode: json['barcode']?.toString(),
        stock: json['stock'],
        isAvailable: json['isAvailable'],
        rating: json['rating']?.toDouble(),
        reviewCount: json['reviewCount'],
        isSoldByWeight: json['isSoldByWeight'],
        pricePerKg: json['pricePerKg']?.toDouble(),
        sellerId: json['sellerId']?.toString(),
        sellerName: json['sellerName']?.toString(),
        sellerEmail: json['sellerEmail']?.toString(),
        sellerPhone: json['sellerPhone']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'barcode': barcode,
        'stock': stock,
        'isAvailable': isAvailable,
        'rating': rating,
        'reviewCount': reviewCount,
        'isSoldByWeight': isSoldByWeight,
        'pricePerKg': pricePerKg,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerEmail': sellerEmail,
        'sellerPhone': sellerPhone,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? barcode,
    int? stock,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    bool? isSoldByWeight,
    double? pricePerKg,
    String? sellerId,
    String? sellerName,
    String? sellerEmail,
    String? sellerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Modelo para paginação
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int? nextPage;
  final int? prevPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
        currentPage: json['currentPage'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        totalItems: json['totalItems'] ?? 0,
        itemsPerPage: json['itemsPerPage'] ?? 10,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
        nextPage: json['nextPage'],
        prevPage: json['prevPage'],
      );

  Map<String, dynamic> toJson() => {
        'currentPage': currentPage,
        'totalPages': totalPages,
        'totalItems': totalItems,
        'itemsPerPage': itemsPerPage,
        'hasNextPage': hasNextPage,
        'hasPrevPage': hasPrevPage,
        'nextPage': nextPage,
        'prevPage': prevPage,
      };
}
