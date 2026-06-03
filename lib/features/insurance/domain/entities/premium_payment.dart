import 'package:equatable/equatable.dart';

/// Represents a premium payment made for an insurance policy
class PremiumPayment extends Equatable {
  final String id;
  final String policyId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final String? milkDeliveryId;
  final String recordedBy;

  const PremiumPayment({
    required this.id,
    required this.policyId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.milkDeliveryId,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [
        id,
        policyId,
        paymentDate,
      ];

  /// Creates a copy of this payment with the given fields replaced
  PremiumPayment copyWith({
    String? id,
    String? policyId,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    String? milkDeliveryId,
    String? recordedBy,
  }) {
    return PremiumPayment(
      id: id ?? this.id,
      policyId: policyId ?? this.policyId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      milkDeliveryId: milkDeliveryId ?? this.milkDeliveryId,
      recordedBy: recordedBy ?? this.recordedBy,
    );
  }

  /// Checks if this payment was deducted from milk delivery
  bool get isFromMilkDeduction =>
      paymentMethod == PaymentMethod.milkDeduction;

  /// Checks if this payment was made manually
  bool get isManualPayment =>
      paymentMethod == PaymentMethod.cash ||
      paymentMethod == PaymentMethod.mobileMoney;
}

/// Method used for premium payment
enum PaymentMethod {
  milkDeduction,
  cash,
  mobileMoney;

  /// Returns a human-readable label for the payment method
  String get label {
    switch (this) {
      case PaymentMethod.milkDeduction:
        return 'Milk Deduction';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
    }
  }

  /// Returns an icon name for the payment method
  String get iconName {
    switch (this) {
      case PaymentMethod.milkDeduction:
        return 'water_drop';
      case PaymentMethod.cash:
        return 'payments';
      case PaymentMethod.mobileMoney:
        return 'phone_android';
    }
  }
}
