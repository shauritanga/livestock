import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/domain/usecases/get_low_stock_products.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_low_stock_products_test.mocks.dart';

@GenerateMocks([InventoryRepository])
void main() {
  late GetLowStockProducts useCase;
  late MockInventoryRepository mockRepository;
  late List<Product> testProducts;
  late DateTime testDate;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GetLowStockProducts(mockRepository);
    testDate = DateTime(2025, 11, 22);
    
    testProducts = [
      Product(
        id: 'prod-1',
        sku: 'SKU-001',
        name: 'Low Stock Product 1',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 100.0,
        currentStock: 15.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: testDate,
        updatedAt: testDate,
        createdBy: 'user-1',
      ),
      Product(
        id: 'prod-2',
        sku: 'SKU-002',
        name: 'Low Stock Product 2',
        category: ProductCategory.veterinarySupplies,
        unitOfMeasure: 'pieces',
        unitPrice: 50.0,
        currentStock: 5.0,
        reorderPoint: 10.0,
        isActive: true,
        createdAt: testDate,
        updatedAt: testDate,
        createdBy: 'user-1',
      ),
      Product(
        id: 'prod-3',
        sku: 'SKU-003',
        name: 'Out of Stock Product',
        category: ProductCategory.seeds,
        unitOfMeasure: 'bags',
        unitPrice: 200.0,
        currentStock: 0.0,
        reorderPoint: 5.0,
        isActive: true,
        createdAt: testDate,
        updatedAt: testDate,
        createdBy: 'user-1',
      ),
    ];
  });

  group('GetLowStockProducts', () {
    test('should return list of low stock products', () async {
      // Arrange
      when(mockRepository.getLowStockProducts())
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testProducts);
      expect(result.length, 3);
      verify(mockRepository.getLowStockProducts()).called(1);
    });

    test('should return empty list when no low stock products', () async {
      // Arrange
      when(mockRepository.getLowStockProducts())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getLowStockProducts()).called(1);
    });

    test('should return products with stock at reorder point', () async {
      // Arrange
      final atReorderPoint = [
        Product(
          id: 'prod-4',
          sku: 'SKU-004',
          name: 'At Reorder Point',
          category: ProductCategory.fertilizers,
          unitOfMeasure: 'kg',
          unitPrice: 150.0,
          currentStock: 20.0,
          reorderPoint: 20.0,
          isActive: true,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-1',
        ),
      ];
      
      when(mockRepository.getLowStockProducts())
          .thenAnswer((_) async => atReorderPoint);

      // Act
      final result = await useCase();

      // Assert
      expect(result, atReorderPoint);
      expect(result.first.isLowStock, true);
      expect(result.first.currentStock, result.first.reorderPoint);
    });

    test('should return products with stock below reorder point', () async {
      // Arrange
      final belowReorderPoint = [
        Product(
          id: 'prod-5',
          sku: 'SKU-005',
          name: 'Below Reorder Point',
          category: ProductCategory.farmEquipment,
          unitOfMeasure: 'pieces',
          unitPrice: 500.0,
          currentStock: 3.0,
          reorderPoint: 10.0,
          isActive: true,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-1',
        ),
      ];
      
      when(mockRepository.getLowStockProducts())
          .thenAnswer((_) async => belowReorderPoint);

      // Act
      final result = await useCase();

      // Assert
      expect(result, belowReorderPoint);
      expect(result.first.isLowStock, true);
      expect(result.first.currentStock, lessThan(result.first.reorderPoint));
    });

    test('should return out of stock products', () async {
      // Arrange
      final outOfStock = [
        Product(
          id: 'prod-6',
          sku: 'SKU-006',
          name: 'Out of Stock',
          category: ProductCategory.other,
          unitOfMeasure: 'units',
          unitPrice: 75.0,
          currentStock: 0.0,
          reorderPoint: 15.0,
          isActive: true,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-1',
        ),
      ];
      
      when(mockRepository.getLowStockProducts())
          .thenAnswer((_) async => outOfStock);

      // Act
      final result = await useCase();

      // Assert
      expect(result, outOfStock);
      expect(result.first.isOutOfStock, true);
      expect(result.first.isLowStock, true);
    });

    test('should handle repository errors', () async {
      // Arrange
      when(mockRepository.getLowStockProducts())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
    });

    test('should verify all returned products are actually low stock', () async {
      // Arrange
      when(mockRepository.getLowStockProducts())
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase();

      // Assert
      for (final product in result) {
        expect(product.isLowStock, true,
            reason: 'Product ${product.name} should be low stock');
      }
    });
  });
}
