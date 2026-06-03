import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/entrance_fee/domain/entities/entrance_fee.dart';

/// Entrance fee data model with JSON serialization
class EntranceFeeModel extends EntranceFee {
  const EntranceFeeModel({
    required super.id,
    required super.farmerId,
    required super.cooperativeId,
    required super.amount,
    required super.paymentDate,
    required super.recordedAt,
  });

  /// Create model from JSON
  factory EntranceFeeModel.fromJson(Map<String, dynamic> json) {
    return EntranceFeeModel(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      cooperativeId: json['cooperativeId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: (json['paymentDate'] as Timestamp).toDate(),
      recordedAt: (json['recordedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'cooperativeId': cooperativeId,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'recordedAt': Timestamp.fromDate(recordedAt),
    };
  }

  /// Create model from entity
  factory EntranceFeeModel.fromEntity(EntranceFee entity) {
    return EntranceFeeModel(
      id: entity.id,
      farmerId: entity.farmerId,
      cooperativeId: entity.cooperativeId,
      amount: entity.amount,
      paymentDate: entity.paymentDate,
      recordedAt: entity.recordedAt,
    );
  }

  /// Convert model to entity
  EntranceFee toEntity() {
    return EntranceFee(
      id: id,
      farmerId: farmerId,
      cooperativeId: cooperativeId,
      amount: amount,
      paymentDate: paymentDate,
      recordedAt: recordedAt,
    );
  }
}
