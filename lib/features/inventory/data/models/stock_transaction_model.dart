import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';

/// Stock transaction model for Firestore serialization
class StockTransactionModel extends StockTransaction {
  const StockTransactionModel({
    required super.id,
    required super.cooperativeId,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.previousStock,
    required super.newStock,
    super.reason,
    required super.timestamp,
    required super.performedBy,
  });

  /// Create StockTransactionModel from StockTransaction entity
  factory StockTransactionModel.fromEntity(StockTransaction transaction) {
    return StockTransactionModel(
      id: transaction.id,
      cooperativeId: transaction.cooperativeId,
      productId: transaction.productId,
      type: transaction.type,
      quantity: transaction.quantity,
      previousStock: transaction.previousStock,
      newStock: transaction.newStock,
      reason: transaction.reason,
      timestamp: transaction.timestamp,
      performedBy: transaction.performedBy,
    );
  }

  /// Create StockTransactionModel from Firestore JSON
  factory StockTransactionModel.fromJson(Map<String, dynamic> json) {
    return StockTransactionModel(
      id: json['id'] as String,
      cooperativeId: json['cooperativeId'] as String,
      productId: json['productId'] as String,
      type: StockTransactionType.fromString(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      previousStock: (json['previousStock'] as num).toDouble(),
      newStock: (json['newStock'] as num).toDouble(),
      reason: json['reason'] as String?,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      performedBy: json['performedBy'] as String,
    );
  }

  /// Convert StockTransactionModel to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'productId': productId,
      'type': type.name,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
      'performedBy': performedBy,
    };
  }

  /// Convert to StockTransaction entity
  StockTransaction toEntity() {
    return StockTransaction(
      id: id,
      cooperativeId: cooperativeId,
      productId: productId,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      reason: reason,
      timestamp: timestamp,
      performedBy: performedBy,
    );
  }

  @override
  StockTransactionModel copyWith({
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
    return StockTransactionModel(
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
}
