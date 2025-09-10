enum DeliveryStatus {
  available('available', 'Disponível'),
  accepted('accepted', 'Aceita'),
  pickingUp('picking_up', 'Coletando'),
  inTransit('in_transit', 'Em Trânsito'),
  delivered('delivered', 'Entregue'),
  cancelled('cancelled', 'Cancelada'),
  returned('returned', 'Devolvida');

  const DeliveryStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Converte string para enum
  static DeliveryStatus fromString(String value) {
    return DeliveryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeliveryStatus.available,
    );
  }

  /// Verifica se pode transicionar para outro status
  bool canTransitionTo(DeliveryStatus newStatus) {
    switch (this) {
      case DeliveryStatus.available:
        return newStatus == DeliveryStatus.accepted || 
               newStatus == DeliveryStatus.cancelled;
      
      case DeliveryStatus.accepted:
        return newStatus == DeliveryStatus.pickingUp || 
               newStatus == DeliveryStatus.cancelled;
      
      case DeliveryStatus.pickingUp:
        return newStatus == DeliveryStatus.inTransit || 
               newStatus == DeliveryStatus.cancelled;
      
      case DeliveryStatus.inTransit:
        return newStatus == DeliveryStatus.delivered || 
               newStatus == DeliveryStatus.returned ||
               newStatus == DeliveryStatus.cancelled;
      
      case DeliveryStatus.delivered:
      case DeliveryStatus.cancelled:
      case DeliveryStatus.returned:
        return false; // Estados finais
    }
  }

  /// Retorna os próximos status possíveis
  List<DeliveryStatus> get nextPossibleStatuses {
    return DeliveryStatus.values
        .where((status) => canTransitionTo(status))
        .toList();
  }

  /// Verifica se é um status final
  bool get isFinal {
    return this == DeliveryStatus.delivered ||
           this == DeliveryStatus.cancelled ||
           this == DeliveryStatus.returned;
  }

  /// Verifica se é um status ativo (entregador está trabalhando)
  bool get isActive {
    return this == DeliveryStatus.accepted ||
           this == DeliveryStatus.pickingUp ||
           this == DeliveryStatus.inTransit;
  }

  /// Retorna a cor associada ao status
  String get colorHex {
    switch (this) {
      case DeliveryStatus.available:
        return '#2196F3'; // Azul
      case DeliveryStatus.accepted:
        return '#FF9800'; // Laranja
      case DeliveryStatus.pickingUp:
        return '#9C27B0'; // Roxo
      case DeliveryStatus.inTransit:
        return '#3F51B5'; // Índigo
      case DeliveryStatus.delivered:
        return '#4CAF50'; // Verde
      case DeliveryStatus.cancelled:
        return '#F44336'; // Vermelho
      case DeliveryStatus.returned:
        return '#795548'; // Marrom
    }
  }

  /// Retorna o ícone associado ao status
  String get iconName {
    switch (this) {
      case DeliveryStatus.available:
        return 'assignment';
      case DeliveryStatus.accepted:
        return 'check_circle';
      case DeliveryStatus.pickingUp:
        return 'shopping_bag';
      case DeliveryStatus.inTransit:
        return 'local_shipping';
      case DeliveryStatus.delivered:
        return 'done_all';
      case DeliveryStatus.cancelled:
        return 'cancel';
      case DeliveryStatus.returned:
        return 'keyboard_return';
    }
  }
}

class DeliveryStatusModel {
  final DeliveryStatus status;
  final DateTime timestamp;
  final String? notes;
  final String? location;
  final String? deliveryPersonId;

  const DeliveryStatusModel({
    required this.status,
    required this.timestamp,
    this.notes,
    this.location,
    this.deliveryPersonId,
  });

  factory DeliveryStatusModel.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusModel(
      status: DeliveryStatus.fromString(json['status'] ?? 'available'),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      location: json['location'],
      deliveryPersonId: json['delivery_person_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'location': location,
      'delivery_person_id': deliveryPersonId,
    };
  }

  /// Cria uma nova instância com status atualizado
  DeliveryStatusModel copyWith({
    DeliveryStatus? status,
    DateTime? timestamp,
    String? notes,
    String? location,
    String? deliveryPersonId,
  }) {
    return DeliveryStatusModel(
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
    );
  }

  @override
  String toString() {
    return 'DeliveryStatusModel(status: ${status.displayName}, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryStatusModel &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.location == location &&
        other.deliveryPersonId == deliveryPersonId;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      timestamp,
      notes,
      location,
      deliveryPersonId,
    );
  }
}