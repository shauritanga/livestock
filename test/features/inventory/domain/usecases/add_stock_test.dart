import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/domain/usecases/add_stock.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_stock_test.mocks.dart';

@GenerateMocks([InventoryRepository])
void main() {
  late AddStock useCase;
  late MockInventoryRepository mockRepository;
  late StockTransaction testTransaction;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = AddStock(mockRepository);
    
    testTransaction = StockTransaction(
      id: 'trans-1',
      productId: 'prod-1',
      type: StockTransactionType.addition,
      quantity: 50.0,
      previousStock: 100.0,
      newStock: 150.0,
      reason: 'New stock arrival',
      timestamp: DateTime(2025, 11, 22),
      performedBy: 'user-1',
    );
  });

  group('AddStock', () {
    test('should successfully add stock with valid data', () async {
      // Arrange
      when(mockRepository.addStock(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        reason: anyNamed('reason'),
        performedBy: anyNamed('performedBy'),
      )).thenAnswer((_) async => testTransaction);

      // Act
      final result = await useCase(
        productId: 'prod-1',
        quantity: 50.0,
        reason: 'New stock arrival',
        performedBy: 'user-1',
      );

      // Assert
      expect(result, testTransaction);
      verify(mockRepository.addStock(
        productId: 'prod-1',
        quantity: 50.0,
        reason: 'New stock arrival',
        performedBy: 'user-1',
      )).called(1);
    });

    test('should successfully add stock without reason', () async {
      // Arrange
      when(mockRepository.addStock(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
        reason: anyNamed('reason'),
        performedBy: anyNamed('performedBy'),
      )).thenAnswer((_) async => testTransaction);

      // Act
      final result = await useCase(
        productId: 'prod-1',
        quantity: 50.0,
        performedBy: 'user-1',
      );

      // Assert
      expect(result, testTransaction);
      verify(mockRepository.addStock(
        productId: 'prod-1',
        quantity: 50.0,
        reason: null,
        performedBy: 'user-1',
      )).called(1);
    });

    group('Quantity Validation', () {
      test('should throw exception when quantity is zero', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            quantity: 0.0,
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Quantity must be a positive number'),
          )),
        );
        verifyNever(mockRepository.addStock(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
          reason: anyNamed('reason'),
          performedBy: anyNamed('performedBy'),
        ));
      });

      test('should throw exception when quantity is negative', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            quantity: -10.0,
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Quantity must be a positive number'),
          )),
        );
      });

      test('should accept decimal quantities', () async {
        // Arrange
        when(mockRepository.addStock(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
          reason: anyNamed('reason'),
          performedBy: anyNamed('performedBy'),
        )).thenAnswer((_) async => testTransaction);

        // Act
        await useCase(
          productId: 'prod-1',
          quantity: 25.5,
          performedBy: 'user-1',
        );

        // Assert
        verify(mockRepository.addStock(
          productId: 'prod-1',
          quantity: 25.5,
          reason: null,
          performedBy: 'user-1',
        )).called(1);
      });
    });

    group('Product ID Validation', () {
      test('should throw exception when product ID is empty', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: '',
            quantity: 50.0,
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Product ID is required'),
          )),
        );
      });

      test('should throw exception when product ID is only whitespace', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: '   ',
            quantity: 50.0,
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Product ID is required'),
          )),
        );
      });
    });

    group('User ID Validation', () {
      test('should throw exception when performed by is empty', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            quantity: 50.0,
            performedBy: '',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User ID is required'),
          )),
        );
      });

      test('should throw exception when performed by is only whitespace', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            quantity: 50.0,
            performedBy: '   ',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User ID is required'),
          )),
        );
      });
    });
  });
}
