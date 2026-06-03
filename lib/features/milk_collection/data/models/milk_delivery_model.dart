import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';

/// Milk delivery model for Firestore serialization
class MilkDeliveryModel extends MilkDelivery {
  const MilkDeliveryModel({
    required super.id,
    required super.farmerId,
    super.cattleId,
    required super.cooperativeId,
    required super.quantityLiters,
    required super.qualityGrade,
    required super.deliveryDate,
    required super.recordedBy,
    required super.createdAt,
    super.paymentBatchId,
  });

  /// Convert Firestore document to MilkDeliveryModel
  factory MilkDeliveryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MilkDeliveryModel(
      id: doc.id,
      farmerId: data['farmerId'] as String,
      cattleId: data['cattleId'] as String?,
      cooperativeId: data['cooperativeId'] as String,
      quantityLiters: (data['quantityLiters'] as num).toDouble(),
      qualityGrade: MilkQualityGrade.values.firstWhere(
        (e) => e.name == data['qualityGrade'],
        orElse: () => MilkQualityGrade.standard,
      ),
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      recordedBy: data['recordedBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentBatchId: data['paymentBatchId'] as String?,
    );
  }

  /// Convert MilkDeliveryModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'farmerId': farmerId,
      'cattleId': cattleId,
      'cooperativeId': cooperativeId,
      'quantityLiters': quantityLiters,
      'qualityGrade': qualityGrade.name,
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'recordedBy': recordedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentBatchId': paymentBatchId,
    };
  }

  /// Convert MilkDelivery entity to MilkDeliveryModel
  factory MilkDeliveryModel.fromEntity(MilkDelivery delivery) {
    return MilkDeliveryModel(
      id: delivery.id,
      farmerId: delivery.farmerId,
      cattleId: delivery.cattleId,
      cooperativeId: delivery.cooperativeId,
      quantityLiters: delivery.quantityLiters,
      qualityGrade: delivery.qualityGrade,
      deliveryDate: delivery.deliveryDate,
      recordedBy: delivery.recordedBy,
      createdAt: delivery.createdAt,
      paymentBatchId: delivery.paymentBatchId,
    );
  }
}
