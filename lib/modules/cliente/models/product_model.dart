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
