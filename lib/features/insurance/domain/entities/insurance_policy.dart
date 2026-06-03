import 'package:equatable/equatable.dart';

/// Represents an insurance policy for livestock coverage
class InsurancePolicy extends Equatable {
  final String id;
  final String farmerId;
  final String cooperativeId;
  final String insurancePartnerId;
  final List<String> coveredCattleIds;
  final double totalPremium;
  final double installmentAmount;
  final PaymentFrequency paymentFrequency;
  final DateTime policyStartDate;
  final DateTime policyEndDate;
  final PolicyStatus status;
  final DateTime nextPaymentDue;
  final double totalPaid;
  final double outstandingPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const InsurancePolicy({
    required this.id,
    required this.farmerId,
    required this.cooperativeId,
    required this.insurancePartnerId,
    required this.coveredCattleIds,
    required this.totalPremium,
    required this.installmentAmount,
    required this.paymentFrequency,
    required this.policyStartDate,
    required this.policyEndDate,
    required this.status,
    required this.nextPaymentDue,
    required this.totalPaid,
    required this.outstandingPremium,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        farmerId,
        status,
        updatedAt,
      ];

  /// Creates a copy of this policy with the given fields replaced
  InsurancePolicy copyWith({
    String? id,
    String? farmerId,
    String? cooperativeId,
    String? insurancePartnerId,
    List<String>? coveredCattleIds,
    double? totalPremium,
    double? installmentAmount,
    PaymentFrequency? paymentFrequency,
    DateTime? policyStartDate,
    DateTime? policyEndDate,
    PolicyStatus? status,
    DateTime? nextPaymentDue,
    double? totalPaid,
    double? outstandingPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return InsurancePolicy(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      insurancePartnerId: insurancePartnerId ?? this.insurancePartnerId,
      coveredCattleIds: coveredCattleIds ?? this.coveredCattleIds,
      totalPremium: totalPremium ?? this.totalPremium,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      policyStartDate: policyStartDate ?? this.policyStartDate,
      policyEndDate: policyEndDate ?? this.policyEndDate,
      status: status ?? this.status,
      nextPaymentDue: nextPaymentDue ?? this.nextPaymentDue,
      totalPaid: totalPaid ?? this.totalPaid,
      outstandingPremium: outstandingPremium ?? this.outstandingPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Checks if the policy is active
  bool get isActive => status == PolicyStatus.active;

  /// Checks if the policy is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final daysUntilExpiry = policyEndDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  /// Gets the number of days until policy expiry
  int get daysUntilExpiry {
    return policyEndDate.difference(DateTime.now()).inDays;
  }

  /// Checks if premium payment is overdue
  bool get isPaymentOverdue {
    return nextPaymentDue.isBefore(DateTime.now());
  }
}

/// Status of an insurance policy
enum PolicyStatus {
  active,
  expired,
  suspended,
  cancelled;

  /// Returns a human-readable label for the status
  String get label {
    switch (this) {
      case PolicyStatus.active:
        return 'Active';
      case PolicyStatus.expired:
        return 'Expired';
      case PolicyStatus.suspended:
        return 'Suspended';
      case PolicyStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Payment frequency for insurance premiums
enum PaymentFrequency {
  monthly,
  quarterly;

  /// Returns a human-readable label for the frequency
  String get label {
    switch (this) {
      case PaymentFrequency.monthly:
        return 'Monthly';
      case PaymentFrequency.quarterly:
        return 'Quarterly';
    }
  }

  /// Returns the number of months between payments
  int get monthsBetweenPayments {
    switch (this) {
      case PaymentFrequency.monthly:
        return 1;
      case PaymentFrequency.quarterly:
        return 3;
    }
  }
}
