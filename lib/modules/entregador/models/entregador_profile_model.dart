enum VehicleType {
  motorcycle('motorcycle', 'Moto'),
  bicycle('bicycle', 'Bicicleta'),
  car('car', 'Carro'),
  scooter('scooter', 'Patinete'),
  onFoot('on_foot', 'A pé');

  const VehicleType(this.value, this.displayName);

  final String value;
  final String displayName;

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => VehicleType.motorcycle,
    );
  }
}

enum DocumentStatus {
  pending('pending', 'Pendente'),
  approved('approved', 'Aprovado'),
  rejected('rejected', 'Rejeitado'),
  expired('expired', 'Expirado');

  const DocumentStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentStatus.pending,
    );
  }
}

class DocumentModel {
  final String type;
  final String? documentNumber;
  final DocumentStatus status;
  final DateTime? expiryDate;
  final String? imageUrl;
  final DateTime? uploadedAt;
  final String? rejectionReason;

  const DocumentModel({
    required this.type,
    this.documentNumber,
    required this.status,
    this.expiryDate,
    this.imageUrl,
    this.uploadedAt,
    this.rejectionReason,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      type: json['type'] ?? '',
      documentNumber: json['document_number'],
      status: DocumentStatus.fromString(json['status'] ?? 'pending'),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      imageUrl: json['image_url'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'document_number': documentNumber,
      'status': status.value,
      'expiry_date': expiryDate?.toIso8601String(),
      'image_url': imageUrl,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isValid {
    return status == DocumentStatus.approved && !isExpired;
  }
}

class EntregadorProfileModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final VehicleType vehicleType;
  final String? vehiclePlate;
  final String? vehicleModel;
  final String? vehicleColor;
  final bool isActive;
  final bool isAvailable;
  final double rating;
  final int totalRatings;
  final DateTime? lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DocumentModel> documents;
  final Map<String, dynamic>? currentLocation;

  const EntregadorProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.vehicleType,
    this.vehiclePlate,
    this.vehicleModel,
    this.vehicleColor,
    required this.isActive,
    required this.isAvailable,
    required this.rating,
    required this.totalRatings,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
    required this.documents,
    this.currentLocation,
  });

  factory EntregadorProfileModel.fromJson(Map<String, dynamic> json) {
    return EntregadorProfileModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      vehicleType: VehicleType.fromString(json['vehicle_type'] ?? 'motorcycle'),
      vehiclePlate: json['vehicle_plate'],
      vehicleModel: json['vehicle_model'],
      vehicleColor: json['vehicle_color'],
      isActive: json['is_active'] ?? false,
      isAvailable: json['is_available'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => DocumentModel.fromJson(doc))
          .toList(),
      currentLocation: json['current_location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'vehicle_type': vehicleType.value,
      'vehicle_plate': vehiclePlate,
      'vehicle_model': vehicleModel,
      'vehicle_color': vehicleColor,
      'is_active': isActive,
      'is_available': isAvailable,
      'rating': rating,
      'total_ratings': totalRatings,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'current_location': currentLocation,
    };
  }

  /// Verifica se todos os documentos obrigatórios estão válidos
  bool get hasValidDocuments {
    final requiredDocs = ['cnh', 'cpf', 'vehicle_registration'];
    
    for (final docType in requiredDocs) {
      final doc = documents.firstWhere(
        (d) => d.type == docType,
        orElse: () => const DocumentModel(type: '', status: DocumentStatus.pending),
      );
      
      if (!doc.isValid) return false;
    }
    
    return true;
  }

  /// Verifica se pode aceitar entregas
  bool get canAcceptDeliveries {
    return isActive && isAvailable && hasValidDocuments;
  }

  /// Retorna a descrição do veículo
  String get vehicleDescription {
    final parts = <String>[];
    
    if (vehicleModel != null) parts.add(vehicleModel!);
    if (vehicleColor != null) parts.add(vehicleColor!);
    if (vehiclePlate != null) parts.add('(${vehiclePlate!})');
    
    if (parts.isEmpty) return vehicleType.displayName;
    
    return '${vehicleType.displayName} - ${parts.join(' ')}';
  }

  /// Retorna o tempo desde a última atividade
  String get lastActiveDescription {
    if (lastActiveAt == null) return 'Nunca ativo';
    
    final difference = DateTime.now().difference(lastActiveAt!);
    
    if (difference.inMinutes < 1) return 'Ativo agora';
    if (difference.inHours < 1) return '${difference.inMinutes}min atrás';
    if (difference.inDays < 1) return '${difference.inHours}h atrás';
    
    return '${difference.inDays}d atrás';
  }

  @override
  String toString() {
    return 'EntregadorProfileModel(id: $id, name: $name, vehicleType: ${vehicleType.displayName}, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntregadorProfileModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, name, email);
  }
}