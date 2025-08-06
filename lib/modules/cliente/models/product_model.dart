class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String barcode;
  final int stock;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final bool isSoldByWeight;
  final double? pricePerKg;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.barcode,
    required this.stock,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isSoldByWeight = false,
    this.pricePerKg,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: json['price'].toDouble(),
    imageUrl: json['imageUrl'],
    category: json['category'],
    barcode: json['barcode'],
    stock: json['stock'],
    isAvailable: json['isAvailable'] ?? true,
    rating: json['rating']?.toDouble() ?? 0.0,
    reviewCount: json['reviewCount'] ?? 0,
    isSoldByWeight: json['isSoldByWeight'] ?? false,
    pricePerKg: json['pricePerKg']?.toDouble(),
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
    );
  }
}