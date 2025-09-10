class DeliveryStatsModel {
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final int cancelledDeliveries;
  final double totalEarnings;
  final double averageRating;
  final int totalRatings;
  final DateTime? lastDeliveryDate;
  final int deliveriesToday;
  final int deliveriesThisWeek;
  final int deliveriesThisMonth;

  const DeliveryStatsModel({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.pendingDeliveries,
    required this.cancelledDeliveries,
    required this.totalEarnings,
    required this.averageRating,
    required this.totalRatings,
    this.lastDeliveryDate,
    required this.deliveriesToday,
    required this.deliveriesThisWeek,
    required this.deliveriesThisMonth,
  });

  factory DeliveryStatsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryStatsModel(
      totalDeliveries: json['total_deliveries'] ?? 0,
      completedDeliveries: json['completed_deliveries'] ?? 0,
      pendingDeliveries: json['pending_deliveries'] ?? 0,
      cancelledDeliveries: json['cancelled_deliveries'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? 0.0).toDouble(),
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      lastDeliveryDate: json['last_delivery_date'] != null
          ? DateTime.parse(json['last_delivery_date'])
          : null,
      deliveriesToday: json['deliveries_today'] ?? 0,
      deliveriesThisWeek: json['deliveries_this_week'] ?? 0,
      deliveriesThisMonth: json['deliveries_this_month'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_deliveries': totalDeliveries,
      'completed_deliveries': completedDeliveries,
      'pending_deliveries': pendingDeliveries,
      'cancelled_deliveries': cancelledDeliveries,
      'total_earnings': totalEarnings,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'last_delivery_date': lastDeliveryDate?.toIso8601String(),
      'deliveries_today': deliveriesToday,
      'deliveries_this_week': deliveriesThisWeek,
      'deliveries_this_month': deliveriesThisMonth,
    };
  }

  /// Calcula a taxa de sucesso das entregas
  double get successRate {
    if (totalDeliveries == 0) return 0.0;
    return (completedDeliveries / totalDeliveries) * 100;
  }

  /// Verifica se o entregador está ativo (fez entregas recentemente)
  bool get isActive {
    if (lastDeliveryDate == null) return false;
    final daysSinceLastDelivery = DateTime.now().difference(lastDeliveryDate!).inDays;
    return daysSinceLastDelivery <= 7; // Ativo se fez entrega nos últimos 7 dias
  }

  /// Retorna o ganho médio por entrega
  double get averageEarningsPerDelivery {
    if (completedDeliveries == 0) return 0.0;
    return totalEarnings / completedDeliveries;
  }

  @override
  String toString() {
    return 'DeliveryStatsModel(totalDeliveries: $totalDeliveries, completedDeliveries: $completedDeliveries, totalEarnings: $totalEarnings, averageRating: $averageRating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryStatsModel &&
        other.totalDeliveries == totalDeliveries &&
        other.completedDeliveries == completedDeliveries &&
        other.pendingDeliveries == pendingDeliveries &&
        other.cancelledDeliveries == cancelledDeliveries &&
        other.totalEarnings == totalEarnings &&
        other.averageRating == averageRating &&
        other.totalRatings == totalRatings &&
        other.lastDeliveryDate == lastDeliveryDate &&
        other.deliveriesToday == deliveriesToday &&
        other.deliveriesThisWeek == deliveriesThisWeek &&
        other.deliveriesThisMonth == deliveriesThisMonth;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalDeliveries,
      completedDeliveries,
      pendingDeliveries,
      cancelledDeliveries,
      totalEarnings,
      averageRating,
      totalRatings,
      lastDeliveryDate,
      deliveriesToday,
      deliveriesThisWeek,
      deliveriesThisMonth,
    );
  }
}