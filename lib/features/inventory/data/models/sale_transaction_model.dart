import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';

/// Sale transaction model for Firestore serialization
class SaleTransactionModel extends SaleTransaction {
  const SaleTransactionModel({
    required super.id,
    required super.cooperativeId,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.totalAmount,
    super.customerName,
    super.notes,
    required super.timestamp,
    required super.processedBy,
    super.isSynced = true,
  });

  /// Create SaleTransactionModel from SaleTransaction entity
  factory SaleTransactionModel.fromEntity(SaleTransaction transaction) {
    return SaleTransactionModel(
      id: transaction.id,
      cooperativeId: transaction.cooperativeId,
      productId: transaction.productId,
      productName: transaction.productName,
      quantity: transaction.quantity,
      unitPrice: transaction.unitPrice,
      totalAmount: transaction.totalAmount,
      customerName: transaction.customerName,
      notes: transaction.notes,
      timestamp: transaction.timestamp,
      processedBy: transaction.processedBy,
      isSynced: transaction.isSynced,
    );
  }

  /// Create SaleTransactionModel from Firestore JSON
  factory SaleTransactionModel.fromJson(Map<String, dynamic> json) {
    return SaleTransactionModel(
      id: json['id'] as String,
      cooperativeId: json['cooperativeId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      customerName: json['customerName'] as String?,
      notes: json['notes'] as String?,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      processedBy: json['processedBy'] as String,
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  /// Convert SaleTransactionModel to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'customerName': customerName,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
      'processedBy': processedBy,
      'isSynced': isSynced,
    };
  }

  /// Convert to SaleTransaction entity
  SaleTransaction toEntity() {
    return SaleTransaction(
      id: id,
      cooperativeId: cooperativeId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      customerName: customerName,
      notes: notes,
      timestamp: timestamp,
      processedBy: processedBy,
      isSynced: isSynced,
    );
  }

  @override
  SaleTransactionModel copyWith({
    String? id,
    String? cooperativeId,
    String? productId,
    String? productName,
    double? quantity,
    double? unitPrice,
    double? totalAmount,
    String? customerName,
    String? notes,
    DateTime? timestamp,
    String? processedBy,
    bool? isSynced,
  }) {
    return SaleTransactionModel(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      processedBy: processedBy ?? this.processedBy,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
