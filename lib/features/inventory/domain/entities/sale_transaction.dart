import 'package:equatable/equatable.dart';

/// Sale transaction entity
class SaleTransaction extends Equatable {
  final String id;
  final String cooperativeId;
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double totalAmount;
  final String? customerName;
  final String? notes;
  final DateTime timestamp;
  final String processedBy;
  final bool isSynced;

  const SaleTransaction({
    required this.id,
    required this.cooperativeId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.customerName,
    this.notes,
    required this.timestamp,
    required this.processedBy,
    this.isSynced = true,
  });

  /// Copy with method for creating modified copies
  SaleTransaction copyWith({
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
    return SaleTransaction(
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

  @override
  List<Object?> get props => [
        id,
        cooperativeId,
        productId,
        productName,
        quantity,
        unitPrice,
        totalAmount,
        customerName,
        notes,
        timestamp,
        processedBy,
        isSynced,
      ];
}
