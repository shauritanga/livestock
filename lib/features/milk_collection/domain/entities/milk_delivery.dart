import 'package:equatable/equatable.dart';

/// Quality grade of milk
enum MilkQualityGrade {
  premium,
  standard,
  substandard,
}

/// Milk delivery entity representing a milk collection record
class MilkDelivery extends Equatable {
  final String id;
  final String farmerId;
  final String? cattleId;
  final String cooperativeId;
  final double quantityLiters;
  final MilkQualityGrade qualityGrade;
  final DateTime deliveryDate;
  final String recordedBy;
  final DateTime createdAt;
  final String? paymentBatchId; // null means unpaid

  const MilkDelivery({
    required this.id,
    required this.farmerId,
    this.cattleId,
    required this.cooperativeId,
    required this.quantityLiters,
    required this.qualityGrade,
    required this.deliveryDate,
    required this.recordedBy,
    required this.createdAt,
    this.paymentBatchId,
  });

  /// Check if this delivery has been paid
  bool get isPaid => paymentBatchId != null;

  /// Get price per liter (default cooperative price)
  /// Note: Actual payment is calculated at batch processing time
  double get pricePerLiter => 1200.0; // Default TZS per liter

  /// Get total amount (estimated based on default price)
  /// Note: Actual payment is calculated at batch processing time
  double get totalAmount => quantityLiters * pricePerLiter;

  @override
  List<Object?> get props => [
        id,
        farmerId,
        cattleId,
        cooperativeId,
        quantityLiters,
        qualityGrade,
        deliveryDate,
        recordedBy,
        createdAt,
        paymentBatchId,
      ];

  MilkDelivery copyWith({
    String? id,
    String? farmerId,
    String? cattleId,
    String? cooperativeId,
    double? quantityLiters,
    MilkQualityGrade? qualityGrade,
    DateTime? deliveryDate,
    String? recordedBy,
    DateTime? createdAt,
    String? paymentBatchId,
  }) {
    return MilkDelivery(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cattleId: cattleId ?? this.cattleId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      quantityLiters: quantityLiters ?? this.quantityLiters,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
      paymentBatchId: paymentBatchId ?? this.paymentBatchId,
    );
  }
}
