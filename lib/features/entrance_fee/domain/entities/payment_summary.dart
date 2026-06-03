import 'package:equatable/equatable.dart';

/// Summary statistics for entrance fee payments
class PaymentSummary extends Equatable {
  final int totalFarmers;
  final int paidCount;
  final int unpaidCount;
  final double totalAmountCollected;

  const PaymentSummary({
    required this.totalFarmers,
    required this.paidCount,
    required this.unpaidCount,
    required this.totalAmountCollected,
  });

  /// Get percentage of farmers who have paid
  double get paymentPercentage {
    if (totalFarmers == 0) return 0.0;
    return (paidCount / totalFarmers) * 100;
  }

  @override
  List<Object?> get props => [
        totalFarmers,
        paidCount,
        unpaidCount,
        totalAmountCollected,
      ];
}
