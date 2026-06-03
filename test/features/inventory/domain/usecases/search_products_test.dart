import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/domain/usecases/search_products.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_products_test.mocks.dart';

@GenerateMocks([InventoryRepository])
void main() {
  late SearchProducts useCase;
  late MockInventoryRepository mockRepository;
  late List<Product> testProducts;
  late DateTime testDate;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = SearchProducts(mockRepository);
    testDate = DateTime(2025, 11, 22);
    
    testProducts = [
      Product(
        id: 'prod-1',
        sku: 'FEED-001',
        name: 'Animal Feed Premium',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 100.0,
        currentStock: 50.0,
        reorderPoint: 20.0,
        isActive: true,
        createdAt: testDate,
        updatedAt: testDate,
        createdBy: 'user-1',
      ),
      Product(
        id: 'prod-2',
        sku: 'FEED-002',
        name: 'Animal Feed Standard',
        category: ProductCategory.animalFeed,
        unitOfMeasure: 'kg',
        unitPrice: 75.0,
        currentStock: 100.0,
        reorderPoint: 30.0,
        isActive: true,
        createdAt: testDate,
        updatedAt: testDate,
        createdBy: 'user-1',
      ),
    ];
  });

  group('SearchProducts', () {
    test('should return matching products for valid query', () async {
      // Arrange
      const query = 'Animal Feed';
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, testProducts);
      expect(result.length, 2);
      verify(mockRepository.searchProducts(query)).called(1);
    });

    test('should trim whitespace from query', () async {
      // Arrange
      const query = '  Animal Feed  ';
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, testProducts);
      verify(mockRepository.searchProducts('Animal Feed')).called(1);
    });

    test('should return empty list for empty query', () async {
      // Arrange
      const query = '';

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, isEmpty);
      verifyNever(mockRepository.searchProducts(any));
    });

    test('should return empty list for whitespace-only query', () async {
      // Arrange
      const query = '   ';

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, isEmpty);
      verifyNever(mockRepository.searchProducts(any));
    });

    test('should search by product name', () async {
      // Arrange
      const query = 'Premium';
      final matchingProducts = [testProducts[0]];
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => matchingProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, matchingProducts);
      expect(result.length, 1);
      expect(result.first.name, contains('Premium'));
      verify(mockRepository.searchProducts(query)).called(1);
    });

    test('should search by SKU', () async {
      // Arrange
      const query = 'FEED-001';
      final matchingProducts = [testProducts[0]];
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => matchingProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, matchingProducts);
      expect(result.length, 1);
      expect(result.first.sku, query);
      verify(mockRepository.searchProducts(query)).called(1);
    });

    test('should return empty list when no matches found', () async {
      // Arrange
      const query = 'NonExistent';
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.searchProducts(query)).called(1);
    });

    test('should handle partial matches', () async {
      // Arrange
      const query = 'Feed';
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, testProducts);
      expect(result.length, 2);
      for (final product in result) {
        expect(
          product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.sku.toLowerCase().contains(query.toLowerCase()),
          true,
        );
      }
    });

    test('should handle case-insensitive search', () async {
      // Arrange
      const query = 'animal feed';
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, testProducts);
      verify(mockRepository.searchProducts(query)).called(1);
    });

    test('should handle single character query', () async {
      // Arrange
      const query = 'A';
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, testProducts);
      verify(mockRepository.searchProducts(query)).called(1);
    });

    test('should handle special characters in query', () async {
      // Arrange
      const query = 'FEED-001';
      final matchingProducts = [testProducts[0]];
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => matchingProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result, matchingProducts);
      verify(mockRepository.searchProducts(query)).called(1);
    });

    test('should handle repository errors', () async {
      // Arrange
      const query = 'Test';
      when(mockRepository.searchProducts(any))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase(query),
        throwsA(isA<Exception>()),
      );
    });

    test('should return products in order returned by repository', () async {
      // Arrange
      const query = 'Feed';
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => testProducts);

      // Act
      final result = await useCase(query);

      // Assert
      expect(result[0].id, testProducts[0].id);
      expect(result[1].id, testProducts[1].id);
    });
  });
}
