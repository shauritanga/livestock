import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';
import 'package:livestock/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:livestock/features/inventory/domain/usecases/adjust_stock.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'adjust_stock_test.mocks.dart';

@GenerateMocks([InventoryRepository])
void main() {
  late AdjustStock useCase;
  late MockInventoryRepository mockRepository;
  late StockTransaction testTransaction;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = AdjustStock(mockRepository);
    
    testTransaction = StockTransaction(
      id: 'trans-1',
      productId: 'prod-1',
      type: StockTransactionType.adjustment,
      quantity: 0.0,
      previousStock: 100.0,
      newStock: 95.0,
      reason: 'Damaged items removed',
      timestamp: DateTime(2025, 11, 22),
      performedBy: 'user-1',
    );
  });

  group('AdjustStock', () {
    test('should successfully adjust stock with valid data', () async {
      // Arrange
      when(mockRepository.adjustStock(
        productId: anyNamed('productId'),
        newStock: anyNamed('newStock'),
        reason: anyNamed('reason'),
        performedBy: anyNamed('performedBy'),
      )).thenAnswer((_) async => testTransaction);

      // Act
      final result = await useCase(
        productId: 'prod-1',
        newStock: 95.0,
        reason: 'Damaged items removed',
        performedBy: 'user-1',
      );

      // Assert
      expect(result, testTransaction);
      verify(mockRepository.adjustStock(
        productId: 'prod-1',
        newStock: 95.0,
        reason: 'Damaged items removed',
        performedBy: 'user-1',
      )).called(1);
    });

    group('Stock Level Validation', () {
      test('should throw exception when new stock is negative', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            newStock: -5.0,
            reason: 'Test adjustment',
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Stock level cannot be negative'),
          )),
        );
        verifyNever(mockRepository.adjustStock(
          productId: anyNamed('productId'),
          newStock: anyNamed('newStock'),
          reason: anyNamed('reason'),
          performedBy: anyNamed('performedBy'),
        ));
      });

      test('should accept zero stock level', () async {
        // Arrange
        when(mockRepository.adjustStock(
          productId: anyNamed('productId'),
          newStock: anyNamed('newStock'),
          reason: anyNamed('reason'),
          performedBy: anyNamed('performedBy'),
        )).thenAnswer((_) async => testTransaction);

        // Act
        await useCase(
          productId: 'prod-1',
          newStock: 0.0,
          reason: 'All stock sold',
          performedBy: 'user-1',
        );

        // Assert
        verify(mockRepository.adjustStock(
          productId: 'prod-1',
          newStock: 0.0,
          reason: 'All stock sold',
          performedBy: 'user-1',
        )).called(1);
      });

      test('should accept decimal stock levels', () async {
        // Arrange
        when(mockRepository.adjustStock(
          productId: anyNamed('productId'),
          newStock: anyNamed('newStock'),
          reason: anyNamed('reason'),
          performedBy: anyNamed('performedBy'),
        )).thenAnswer((_) async => testTransaction);

        // Act
        await useCase(
          productId: 'prod-1',
          newStock: 47.5,
          reason: 'Partial damage',
          performedBy: 'user-1',
        );

        // Assert
        verify(mockRepository.adjustStock(
          productId: 'prod-1',
          newStock: 47.5,
          reason: 'Partial damage',
          performedBy: 'user-1',
        )).called(1);
      });
    });

    group('Reason Validation', () {
      test('should throw exception when reason is empty', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            newStock: 95.0,
            reason: '',
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Reason is required for stock adjustments'),
          )),
        );
      });

      test('should throw exception when reason is only whitespace', () async {
        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            newStock: 95.0,
            reason: '   ',
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Reason is required for stock adjustments'),
          )),
        );
      });

      test('should throw exception when reason exceeds 500 characters', () async {
        // Arrange
        final longReason = 'A' * 501;

        // Act & Assert
        expect(
          () => useCase(
            productId: 'prod-1',
            newStock: 95.0,
            reason: longReason,
            performedBy: 'user-1',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Reason must not exceed 500 characters'),
          )),
        );
      });

      test('should accept reason with exactly 500 characters', () async {
        // Arrange
        final validReason = 'A' * 500;
        when(mockRepository.adjustStock(
          productId: anyNamed('productId'),
          newStock: anyNamed('newStock'),
          reason: anyNamed('reason'),
          performedBy: anyNamed('performedBy'),
        )).thenAnswer((_) async => testTransaction);

        // Act
        await useCase(
          productId: 'prod-1',
          newStock: 95.0,
          reason: validReason,
          performedBy: 'user-1',
        );

        // Assert
        verify(mockRepository.adjustStock(
          productId: 'prod-1',
          newStock: 95.0,
          reason: validReason,
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
            newStock: 95.0,
            reason: 'Test adjustment',
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
            newStock: 95.0,
            reason: 'Test adjustment',
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
            newStock: 95.0,
            reason: 'Test adjustment',
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
            newStock: 95.0,
            reason: 'Test adjustment',
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
