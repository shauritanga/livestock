import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';

/// Insurance policy model for Firestore serialization
class InsurancePolicyModel extends InsurancePolicy {
  const InsurancePolicyModel({
    required super.id,
    required super.farmerId,
    required super.cooperativeId,
    required super.insurancePartnerId,
    required super.coveredCattleIds,
    required super.totalPremium,
    required super.installmentAmount,
    required super.paymentFrequency,
    required super.policyStartDate,
    required super.policyEndDate,
    required super.status,
    required super.nextPaymentDue,
    required super.totalPaid,
    required super.outstandingPremium,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  /// Convert Firestore document to InsurancePolicyModel
  factory InsurancePolicyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InsurancePolicyModel(
      id: doc.id,
      farmerId: data['farmerId'] as String,
      cooperativeId: data['cooperativeId'] as String,
      insurancePartnerId: data['insurancePartnerId'] as String,
      coveredCattleIds: List<String>.from(data['coveredCattleIds'] as List),
      totalPremium: (data['totalPremium'] as num).toDouble(),
      installmentAmount: (data['installmentAmount'] as num).toDouble(),
      paymentFrequency: PaymentFrequency.values.firstWhere(
        (e) => e.name == data['paymentFrequency'],
        orElse: () => PaymentFrequency.monthly,
      ),
      policyStartDate: (data['policyStartDate'] as Timestamp).toDate(),
      policyEndDate: (data['policyEndDate'] as Timestamp).toDate(),
      status: PolicyStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PolicyStatus.active,
      ),
      nextPaymentDue: (data['nextPaymentDue'] as Timestamp).toDate(),
      totalPaid: (data['totalPaid'] as num).toDouble(),
      outstandingPremium: (data['outstandingPremium'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
    );
  }

  /// Convert InsurancePolicyModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'farmerId': farmerId,
      'cooperativeId': cooperativeId,
      'insurancePartnerId': insurancePartnerId,
      'coveredCattleIds': coveredCattleIds,
      'totalPremium': totalPremium,
      'installmentAmount': installmentAmount,
      'paymentFrequency': paymentFrequency.name,
      'policyStartDate': Timestamp.fromDate(policyStartDate),
      'policyEndDate': Timestamp.fromDate(policyEndDate),
      'status': status.name,
      'nextPaymentDue': Timestamp.fromDate(nextPaymentDue),
      'totalPaid': totalPaid,
      'outstandingPremium': outstandingPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  /// Convert InsurancePolicy entity to InsurancePolicyModel
  factory InsurancePolicyModel.fromEntity(InsurancePolicy policy) {
    return InsurancePolicyModel(
      id: policy.id,
      farmerId: policy.farmerId,
      cooperativeId: policy.cooperativeId,
      insurancePartnerId: policy.insurancePartnerId,
      coveredCattleIds: policy.coveredCattleIds,
      totalPremium: policy.totalPremium,
      installmentAmount: policy.installmentAmount,
      paymentFrequency: policy.paymentFrequency,
      policyStartDate: policy.policyStartDate,
      policyEndDate: policy.policyEndDate,
      status: policy.status,
      nextPaymentDue: policy.nextPaymentDue,
      totalPaid: policy.totalPaid,
      outstandingPremium: policy.outstandingPremium,
      createdAt: policy.createdAt,
      updatedAt: policy.updatedAt,
      createdBy: policy.createdBy,
    );
  }

  /// Convert InsurancePolicyModel to InsurancePolicy entity
  InsurancePolicy toEntity() {
    return InsurancePolicy(
      id: id,
      farmerId: farmerId,
      cooperativeId: cooperativeId,
      insurancePartnerId: insurancePartnerId,
      coveredCattleIds: coveredCattleIds,
      totalPremium: totalPremium,
      installmentAmount: installmentAmount,
      paymentFrequency: paymentFrequency,
      policyStartDate: policyStartDate,
      policyEndDate: policyEndDate,
      status: status,
      nextPaymentDue: nextPaymentDue,
      totalPaid: totalPaid,
      outstandingPremium: outstandingPremium,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }
}
