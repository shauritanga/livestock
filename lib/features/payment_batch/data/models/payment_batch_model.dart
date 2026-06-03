import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/payment_batch/domain/entities/payment_batch.dart';

/// Payment batch data model with JSON serialization
class PaymentBatchModel extends PaymentBatch {
  const PaymentBatchModel({
    required super.id,
    required super.cooperativeId,
    required super.periodStart,
    required super.periodEnd,
    required super.status,
    required super.totalFarmers,
    required super.totalAmount,
    super.processedDate,
    super.paymentMethod,
    super.batchReference,
    required super.createdBy,
    required super.createdAt,
  });

  /// Create model from JSON
  factory PaymentBatchModel.fromJson(Map<String, dynamic> json) {
    return PaymentBatchModel(
      id: json['id'] as String,
      cooperativeId: json['cooperativeId'] as String,
      periodStart: (json['periodStart'] as Timestamp).toDate(),
      periodEnd: (json['periodEnd'] as Timestamp).toDate(),
      status: PaymentBatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentBatchStatus.draft,
      ),
      totalFarmers: json['totalFarmers'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      processedDate: json['processedDate'] != null
          ? (json['processedDate'] as Timestamp).toDate()
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      batchReference: json['batchReference'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
      'status': status.name,
      'totalFarmers': totalFarmers,
      'totalAmount': totalAmount,
      'processedDate': processedDate != null
          ? Timestamp.fromDate(processedDate!)
          : null,
      'paymentMethod': paymentMethod,
      'batchReference': batchReference,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create model from entity
  factory PaymentBatchModel.fromEntity(PaymentBatch entity) {
    return PaymentBatchModel(
      id: entity.id,
      cooperativeId: entity.cooperativeId,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      status: entity.status,
      totalFarmers: entity.totalFarmers,
      totalAmount: entity.totalAmount,
      processedDate: entity.processedDate,
      paymentMethod: entity.paymentMethod,
      batchReference: entity.batchReference,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }

  /// Convert model to entity
  PaymentBatch toEntity() {
    return PaymentBatch(
      id: id,
      cooperativeId: cooperativeId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      status: status,
      totalFarmers: totalFarmers,
      totalAmount: totalAmount,
      processedDate: processedDate,
      paymentMethod: paymentMethod,
      batchReference: batchReference,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
