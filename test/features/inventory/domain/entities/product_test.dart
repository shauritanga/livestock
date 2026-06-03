import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';

void main() {
  group('Product Entity', () {
    test('should create product with all required fields', () {
      // Arrange & Act
      final product = Product(
        id: '1',
        cooperativeId: 'coop1',
        sku: 'SKU001',
        name: 'Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 50.0,
        currentStock: 100.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      // Assert
      expect(product.id, '1');
      expect(product.name, 'Animal Feed');
      expect(product.currentStock, 100.0);
      expect(product.isActive, true);
    });

    test('should detect low stock when current stock is at reorder point', () {
      // Arrange
      final product = Product(
        id: '1',
        cooperativeId: 'coop1',
        sku: 'SKU001',
        name: 'Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 50.0,
        currentStock: 20.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      // Act
      final isLowStock = product.isLowStock;

      // Assert
      expect(isLowStock, true);
    });

    test('should detect low stock when current stock is below reorder point', () {
      // Arrange
      final product = Product(
        id: '1',
        cooperativeId: 'coop1',
        sku: 'SKU001',
        name: 'Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 50.0,
        currentStock: 15.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      // Act
      final isLowStock = product.isLowStock;

      // Assert
      expect(isLowStock, true);
    });

    test('should not detect low stock when current stock is above reorder point', () {
      // Arrange
      final product = Product(
        id: '1',
        cooperativeId: 'coop1',
        sku: 'SKU001',
        name: 'Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 50.0,
        currentStock: 50.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      // Act
      final isLowStock = product.isLowStock;

      // Assert
      expect(isLowStock, false);
    });

    test('should detect out of stock when current stock is zero', () {
      // Arrange
      final product = Product(
        id: '1',
        cooperativeId: 'coop1',
        sku: 'SKU001',
        name: 'Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 50.0,
        currentStock: 0.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      // Act
      final isOutOfStock = product.isOutOfStock;

      // Assert
      expect(isOutOfStock, true);
    });

    test('should support equality comparison', () {
      // Arrange
      final product1 = Product(
        id: '1',
        cooperativeId: 'coop1',
        sku: 'SKU001',
        name: 'Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 50.0,
        currentStock: 100.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      final product2 = Product(
        id: '1',
        cooperativeId: 'coop1',
        sku: 'SKU001',
        name: 'Animal Feed',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 50.0,
        currentStock: 100.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      // Assert
      expect(product1, equals(product2));
    });
  });
}
