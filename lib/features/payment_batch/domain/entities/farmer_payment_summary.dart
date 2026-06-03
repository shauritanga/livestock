import 'package:equatable/equatable.dart';

/// Farmer payment summary entity for a payment batch
class FarmerPaymentSummary extends Equatable {
  final String farmerId;
  final String farmerName;
  final String paymentBatchId;
  final int deliveryCount;
  final double totalQuantity;
  final double pricePerLiter;
  final double totalAmount;
  final List<String> deliveryIds;

  const FarmerPaymentSummary({
    required this.farmerId,
    required this.farmerName,
    required this.paymentBatchId,
    required this.deliveryCount,
    required this.totalQuantity,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.deliveryIds,
  });

  /// Get formatted amount with currency
  String getFormattedAmount({String currency = 'TZS'}) {
    return '$currency ${totalAmount.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        farmerId,
        farmerName,
        paymentBatchId,
        deliveryCount,
        totalQuantity,
        pricePerLiter,
        totalAmount,
        deliveryIds,
      ];
}
