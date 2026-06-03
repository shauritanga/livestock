import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/domain/usecases/register_product.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_product_test.mocks.dart';

@GenerateMocks([InventoryRepository])
void main() {
  late RegisterProduct useCase;
  late MockInventoryRepository mockRepository;
  late Product testProduct;
  late DateTime testDate;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = RegisterProduct(mockRepository);
    testDate = DateTime(2025, 11, 22);
    
    testProduct = Product(
      id: 'prod-1',
      sku: 'SKU-001',
      name: 'Test Product',
      category: ProductCategory.animalFeed,
      unitOfMeasure: 'kg',
      unitPrice: 100.0,
      currentStock: 50.0,
      reorderPoint: 20.0,
      isActive: true,
      createdAt: testDate,
      updatedAt: testDate,
      createdBy: 'user-1',
    );
  });

  group('RegisterProduct', () {
    test('should successfully register a valid product', () async {
      // Arrange
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => []);
      when(mockRepository.createProduct(any))
          .thenAnswer((_) async => testProduct);

      // Act
      final result = await useCase(testProduct);

      // Assert
      expect(result, testProduct);
      verify(mockRepository.searchProducts(testProduct.sku)).called(1);
      verify(mockRepository.createProduct(testProduct)).called(1);
    });

    group('Name Validation', () {
      test('should throw exception when name is empty', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(name: '');

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Product name is required'),
          )),
        );
        verifyNever(mockRepository.createProduct(any));
      });

      test('should throw exception when name is only whitespace', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(name: '   ');

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Product name is required'),
          )),
        );
      });

      test('should throw exception when name is too short', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(name: 'A');

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('must be between 2 and 100 characters'),
          )),
        );
      });

      test('should throw exception when name is too long', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(name: 'A' * 101);

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('must be between 2 and 100 characters'),
          )),
        );
      });

      test('should accept name with exactly 2 characters', () async {
        // Arrange
        final validProduct = testProduct.copyWith(name: 'AB');
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });

      test('should accept name with exactly 100 characters', () async {
        // Arrange
        final validProduct = testProduct.copyWith(name: 'A' * 100);
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });
    });

    group('SKU Validation', () {
      test('should throw exception when SKU is empty', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(sku: '');

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('SKU is required'),
          )),
        );
      });

      test('should throw exception when SKU contains invalid characters', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(sku: 'SKU@123');

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('must contain only alphanumeric characters'),
          )),
        );
      });

      test('should accept SKU with alphanumeric characters', () async {
        // Arrange
        final validProduct = testProduct.copyWith(sku: 'SKU123');
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });

      test('should accept SKU with hyphens', () async {
        // Arrange
        final validProduct = testProduct.copyWith(sku: 'SKU-123');
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });

      test('should accept SKU with underscores', () async {
        // Arrange
        final validProduct = testProduct.copyWith(sku: 'SKU_123');
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });

      test('should throw exception when SKU already exists', () async {
        // Arrange
        final existingProduct = Product(
          id: 'prod-2',
          sku: 'SKU-001',
          name: 'Existing Product',
          category: ProductCategory.animalFeed,
          unitOfMeasure: 'kg',
          unitPrice: 100.0,
          currentStock: 50.0,
          reorderPoint: 20.0,
          isActive: true,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-1',
        );
        
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => [existingProduct]);

        // Act & Assert
        expect(
          () => useCase(testProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('SKU already exists'),
          )),
        );
        verifyNever(mockRepository.createProduct(any));
      });

      test('should allow same SKU for same product (update scenario)', () async {
        // Arrange
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => [testProduct]);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => testProduct);

        // Act
        await useCase(testProduct);

        // Assert
        verify(mockRepository.createProduct(testProduct)).called(1);
      });
    });

    group('Price Validation', () {
      test('should throw exception when unit price is zero', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(unitPrice: 0.0);

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unit price must be a positive number'),
          )),
        );
      });

      test('should throw exception when unit price is negative', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(unitPrice: -10.0);

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unit price must be a positive number'),
          )),
        );
      });

      test('should accept positive unit price', () async {
        // Arrange
        final validProduct = testProduct.copyWith(unitPrice: 99.99);
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });
    });

    group('Reorder Point Validation', () {
      test('should throw exception when reorder point is negative', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(reorderPoint: -5.0);

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Reorder point cannot be negative'),
          )),
        );
      });

      test('should accept zero reorder point', () async {
        // Arrange
        final validProduct = testProduct.copyWith(reorderPoint: 0.0);
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });
    });

    group('Initial Stock Validation', () {
      test('should throw exception when initial stock is negative', () async {
        // Arrange
        final invalidProduct = testProduct.copyWith(currentStock: -10.0);

        // Act & Assert
        expect(
          () => useCase(invalidProduct),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Initial stock cannot be negative'),
          )),
        );
      });

      test('should accept zero initial stock', () async {
        // Arrange
        final validProduct = testProduct.copyWith(currentStock: 0.0);
        when(mockRepository.searchProducts(any))
            .thenAnswer((_) async => []);
        when(mockRepository.createProduct(any))
            .thenAnswer((_) async => validProduct);

        // Act
        await useCase(validProduct);

        // Assert
        verify(mockRepository.createProduct(validProduct)).called(1);
      });
    });
  });
}
