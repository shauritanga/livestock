import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/milk_sales/domain/entities/milk_sale.dart';

/// Milk sale data model with JSON serialization
class MilkSaleModel extends MilkSale {
  const MilkSaleModel({
    required super.id,
    required super.cooperativeId,
    super.offTakerId,
    super.customerName,
    required super.quantityLiters,
    required super.pricePerLiter,
    required super.totalAmount,
    required super.saleDate,
    required super.recordedBy,
    required super.createdAt,
  });

  /// Create model from JSON
  factory MilkSaleModel.fromJson(Map<String, dynamic> json) {
    return MilkSaleModel(
      id: json['id'] as String,
      cooperativeId: json['cooperativeId'] as String,
      offTakerId: json['offTakerId'] as String?,
      customerName: json['customerName'] as String?,
      quantityLiters: (json['quantityLiters'] as num).toDouble(),
      pricePerLiter: (json['pricePerLiter'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      saleDate: (json['saleDate'] as Timestamp).toDate(),
      recordedBy: json['recordedBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'offTakerId': offTakerId,
      'customerName': customerName,
      'quantityLiters': quantityLiters,
      'pricePerLiter': pricePerLiter,
      'totalAmount': totalAmount,
      'saleDate': Timestamp.fromDate(saleDate),
      'recordedBy': recordedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create model from entity
  factory MilkSaleModel.fromEntity(MilkSale entity) {
    return MilkSaleModel(
      id: entity.id,
      cooperativeId: entity.cooperativeId,
      offTakerId: entity.offTakerId,
      customerName: entity.customerName,
      quantityLiters: entity.quantityLiters,
      pricePerLiter: entity.pricePerLiter,
      totalAmount: entity.totalAmount,
      saleDate: entity.saleDate,
      recordedBy: entity.recordedBy,
      createdAt: entity.createdAt,
    );
  }

  /// Convert model to entity
  MilkSale toEntity() {
    return MilkSale(
      id: id,
      cooperativeId: cooperativeId,
      offTakerId: offTakerId,
      customerName: customerName,
      quantityLiters: quantityLiters,
      pricePerLiter: pricePerLiter,
      totalAmount: totalAmount,
      saleDate: saleDate,
      recordedBy: recordedBy,
      createdAt: createdAt,
    );
  }
}
