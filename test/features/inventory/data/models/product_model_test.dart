import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/data/models/product_model.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';

void main() {
  group('ProductModel', () {
    final testDate = DateTime(2024, 1, 1);
    final testTimestamp = Timestamp.fromDate(testDate);

    final testJson = {
      'id': 'product1',
      'cooperativeId': 'coop1',
      'sku': 'SKU001',
      'name': 'Animal Feed',
      'category': 'animalFeed',
      'unitOfMeasure': 'kg',
      'unitPrice': 50.0,
      'currentStock': 100.0,
      'reorderPoint': 20.0,
      'isActive': true,
      'createdAt': testTimestamp,
      'updatedAt': testTimestamp,
      'createdBy': 'user1',
    };

    final testModel = ProductModel(
      id: 'product1',
      cooperativeId: 'coop1',
      sku: 'SKU001',
      name: 'Animal Feed',
      category: ProductCategory.animalFeed,
      unitOfMeasure: 'kg',
      unitPrice: 50.0,
      currentStock: 100.0,
      reorderPoint: 20.0,
      isActive: true,
      createdAt: testDate,
      updatedAt: testDate,
      createdBy: 'user1',
    );

    test('should deserialize from JSON correctly', () {
      // Act
      final result = ProductModel.fromJson(testJson);

      // Assert
      expect(result.id, 'product1');
      expect(result.cooperativeId, 'coop1');
      expect(result.sku, 'SKU001');
      expect(result.name, 'Animal Feed');
      expect(result.category, ProductCategory.animalFeed);
      expect(result.unitOfMeasure, 'kg');
      expect(result.unitPrice, 50.0);
      expect(result.currentStock, 100.0);
      expect(result.reorderPoint, 20.0);
      expect(result.isActive, true);
      expect(result.createdBy, 'user1');
    });

    test('should serialize to JSON correctly', () {
      // Act
      final result = testModel.toJson();

      // Assert
      expect(result['id'], 'product1');
      expect(result['cooperativeId'], 'coop1');
      expect(result['sku'], 'SKU001');
      expect(result['name'], 'Animal Feed');
      expect(result['category'], 'animalFeed');
      expect(result['unitOfMeasure'], 'kg');
      expect(result['unitPrice'], 50.0);
      expect(result['currentStock'], 100.0);
      expect(result['reorderPoint'], 20.0);
      expect(result['isActive'], true);
      expect(result['createdBy'], 'user1');
    });

    test('should convert to entity correctly', () {
      // Act
      final entity = testModel.toEntity();

      // Assert
      expect(entity.id, testModel.id);
      expect(entity.cooperativeId, testModel.cooperativeId);
      expect(entity.sku, testModel.sku);
      expect(entity.name, testModel.name);
      expect(entity.category, testModel.category);
      expect(entity.currentStock, testModel.currentStock);
    });

    test('should handle numeric types correctly in fromJson', () {
      // Arrange
      final jsonWithInt = {
        ...testJson,
        'unitPrice': 50, // int instead of double
        'currentStock': 100, // int instead of double
        'reorderPoint': 20, // int instead of double
      };

      // Act
      final result = ProductModel.fromJson(jsonWithInt);

      // Assert
      expect(result.unitPrice, 50.0);
      expect(result.currentStock, 100.0);
      expect(result.reorderPoint, 20.0);
    });
  });
}
