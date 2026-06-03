import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';

/// Premium payment model for Firestore serialization
class PremiumPaymentModel extends PremiumPayment {
  const PremiumPaymentModel({
    required super.id,
    required super.policyId,
    required super.amount,
    required super.paymentDate,
    required super.paymentMethod,
    super.milkDeliveryId,
    required super.recordedBy,
  });

  /// Convert Firestore document to PremiumPaymentModel
  factory PremiumPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PremiumPaymentModel(
      id: doc.id,
      policyId: data['policyId'] as String,
      amount: (data['amount'] as num).toDouble(),
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == data['paymentMethod'],
        orElse: () => PaymentMethod.milkDeduction,
      ),
      milkDeliveryId: data['milkDeliveryId'] as String?,
      recordedBy: data['recordedBy'] as String,
    );
  }

  /// Convert PremiumPaymentModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'policyId': policyId,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'paymentMethod': paymentMethod.name,
      'milkDeliveryId': milkDeliveryId,
      'recordedBy': recordedBy,
    };
  }

  /// Convert PremiumPayment entity to PremiumPaymentModel
  factory PremiumPaymentModel.fromEntity(PremiumPayment payment) {
    return PremiumPaymentModel(
      id: payment.id,
      policyId: payment.policyId,
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      paymentMethod: payment.paymentMethod,
      milkDeliveryId: payment.milkDeliveryId,
      recordedBy: payment.recordedBy,
    );
  }

  /// Convert PremiumPaymentModel to PremiumPayment entity
  PremiumPayment toEntity() {
    return PremiumPayment(
      id: id,
      policyId: policyId,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      milkDeliveryId: milkDeliveryId,
      recordedBy: recordedBy,
    );
  }
}
