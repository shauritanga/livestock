import 'package:equatable/equatable.dart';

/// Milk sale entity representing a sale transaction
class MilkSale extends Equatable {
  final String id;
  final String cooperativeId;
  final String? offTakerId;
  final String? customerName;
  final double quantityLiters;
  final double pricePerLiter;
  final double totalAmount;
  final DateTime saleDate;
  final String recordedBy;
  final DateTime createdAt;

  const MilkSale({
    required this.id,
    required this.cooperativeId,
    this.offTakerId,
    this.customerName,
    required this.quantityLiters,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.saleDate,
    required this.recordedBy,
    required this.createdAt,
  });

  /// Validate sale data
  bool get isValid {
    return quantityLiters > 0 &&
        pricePerLiter > 0 &&
        totalAmount > 0 &&
        !saleDate.isAfter(DateTime.now());
  }

  /// Get formatted amount with currency
  String getFormattedAmount({String currency = 'TZS'}) {
    return '$currency ${totalAmount.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        id,
        cooperativeId,
        offTakerId,
        customerName,
        quantityLiters,
        pricePerLiter,
        totalAmount,
        saleDate,
        recordedBy,
        createdAt,
      ];

  MilkSale copyWith({
    String? id,
    String? cooperativeId,
    String? offTakerId,
    String? customerName,
    double? quantityLiters,
    double? pricePerLiter,
    double? totalAmount,
    DateTime? saleDate,
    String? recordedBy,
    DateTime? createdAt,
  }) {
    return MilkSale(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      offTakerId: offTakerId ?? this.offTakerId,
      customerName: customerName ?? this.customerName,
      quantityLiters: quantityLiters ?? this.quantityLiters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalAmount: totalAmount ?? this.totalAmount,
      saleDate: saleDate ?? this.saleDate,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
