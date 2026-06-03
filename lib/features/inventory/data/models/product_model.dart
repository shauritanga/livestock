import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';

/// Product model for Firestore serialization
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.cooperativeId,
    required super.sku,
    required super.name,
    required super.category,
    required super.unitOfMeasure,
    required super.unitPrice,
    required super.currentStock,
    required super.reorderPoint,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  /// Create ProductModel from Product entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      cooperativeId: product.cooperativeId,
      sku: product.sku,
      name: product.name,
      category: product.category,
      unitOfMeasure: product.unitOfMeasure,
      unitPrice: product.unitPrice,
      currentStock: product.currentStock,
      reorderPoint: product.reorderPoint,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      createdBy: product.createdBy,
    );
  }

  /// Create ProductModel from Firestore JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      cooperativeId: json['cooperativeId'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      category: ProductCategory.fromString(json['category'] as String),
      unitOfMeasure: json['unitOfMeasure'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      currentStock: (json['currentStock'] as num).toDouble(),
      reorderPoint: (json['reorderPoint'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] as String,
    );
  }

  /// Convert ProductModel to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'sku': sku,
      'name': name,
      'category': category.name,
      'unitOfMeasure': unitOfMeasure,
      'unitPrice': unitPrice,
      'currentStock': currentStock,
      'reorderPoint': reorderPoint,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  /// Convert to Product entity
  Product toEntity() {
    return Product(
      id: id,
      cooperativeId: cooperativeId,
      sku: sku,
      name: name,
      category: category,
      unitOfMeasure: unitOfMeasure,
      unitPrice: unitPrice,
      currentStock: currentStock,
      reorderPoint: reorderPoint,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
    );
  }

  @override
  ProductModel copyWith({
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
    return ProductModel(
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
}
