import 'package:equatable/equatable.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';

/// Stock transaction entity for audit trail
class StockTransaction extends Equatable {
  final String id;
  final String cooperativeId;
  final String productId;
  final StockTransactionType type;
  final double quantity;
  final double previousStock;
  final double newStock;
  final String? reason;
  final DateTime timestamp;
  final String performedBy;

  const StockTransaction({
    required this.id,
    required this.cooperativeId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.reason,
    required this.timestamp,
    required this.performedBy,
  });

  /// Get quantity change with sign
  double get quantityChange {
    switch (type) {
      case StockTransactionType.addition:
        return quantity;
      case StockTransactionType.sale:
        return -quantity;
      case StockTransactionType.adjustment:
        return newStock - previousStock;
    }
  }

  /// Copy with method for creating modified copies
  StockTransaction copyWith({
    String? id,
    String? cooperativeId,
    String? productId,
    StockTransactionType? type,
    double? quantity,
    double? previousStock,
    double? newStock,
    String? reason,
    DateTime? timestamp,
    String? performedBy,
  }) {
    return StockTransaction(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      performedBy: performedBy ?? this.performedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cooperativeId,
        productId,
        type,
        quantity,
        previousStock,
        newStock,
        reason,
        timestamp,
        performedBy,
      ];
}
