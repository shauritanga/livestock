import 'package:equatable/equatable.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';

/// Product entity representing an inventory item
class Product extends Equatable {
  final String id;
  final String cooperativeId;
  final String sku;
  final String name;
  final ProductCategory category;
  final String unitOfMeasure;
  final double unitPrice;
  final double currentStock;
  final double reorderPoint;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Product({
    required this.id,
    required this.cooperativeId,
    required this.sku,
    required this.name,
    required this.category,
    required this.unitOfMeasure,
    required this.unitPrice,
    required this.currentStock,
    required this.reorderPoint,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  /// Check if product is low on stock
  bool get isLowStock => currentStock <= reorderPoint;

  /// Check if product is out of stock
  bool get isOutOfStock => currentStock <= 0;

  /// Get stock status as string
  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  /// Calculate total inventory value
  double get inventoryValue => currentStock * unitPrice;

  /// Copy with method for creating modified copies
  Product copyWith({
    String? id,
    String? cooperativeId,
    String? sku,
    String? name,
    ProductCategory? category,
    String? unitOfMeasure,
    double? unitPrice,
    double? currentStock,
    double? reorderPoint,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Product(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitPrice: unitPrice ?? this.unitPrice,
      currentStock: currentStock ?? this.currentStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cooperativeId,
        sku,
        name,
        category,
        unitOfMeasure,
        unitPrice,
        currentStock,
        reorderPoint,
        isActive,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
