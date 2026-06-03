import 'package:equatable/equatable.dart';

/// Entrance fee entity representing a one-time payment by a farmer
class EntranceFee extends Equatable {
  final String id;
  final String farmerId;
  final String cooperativeId;
  final double amount;
  final DateTime paymentDate;
  final DateTime recordedAt;

  const EntranceFee({
    required this.id,
    required this.farmerId,
    required this.cooperativeId,
    required this.amount,
    required this.paymentDate,
    required this.recordedAt,
  });

  /// Validate entrance fee data
  bool get isValid {
    return amount > 0 && !paymentDate.isAfter(DateTime.now());
  }

  /// Get formatted amount with currency
  String getFormattedAmount({String currency = 'TZS'}) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Copy with method for creating modified copies
  EntranceFee copyWith({
    String? id,
    String? farmerId,
    String? cooperativeId,
    double? amount,
    DateTime? paymentDate,
    DateTime? recordedAt,
  }) {
    return EntranceFee(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        farmerId,
        cooperativeId,
        amount,
        paymentDate,
        recordedAt,
      ];
}
