import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/data/models/stock_transaction_model.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction.dart';
import 'package:livestock/features/inventory/domain/entities/stock_transaction_type.dart';

void main() {
  late StockTransactionModel testModel;
  late DateTime testDate;
  late Map<String, dynamic> testJson;

  setUp(() {
    testDate = DateTime(2025, 11, 22, 10, 30);
    
    testModel = StockTransactionModel(
      id: 'trans-1',
      productId: 'prod-1',
      type: StockTransactionType.addition,
      quantity: 50.0,
      previousStock: 100.0,
      newStock: 150.0,
      reason: 'New stock arrival',
      timestamp: testDate,
      performedBy: 'user-1',
    );

    testJson = {
      'id': 'trans-1',
      'productId': 'prod-1',
      'type': 'addition',
      'quantity': 50.0,
      'previousStock': 100.0,
      'newStock': 150.0,
      'reason': 'New stock arrival',
      'timestamp': Timestamp.fromDate(testDate),
      'performedBy': 'user-1',
    };
  });

  group('StockTransactionModel', () {
    group('fromJson', () {
      test('should create StockTransactionModel from valid JSON', () {
        // Act
        final result = StockTransactionModel.fromJson(testJson);

        // Assert
        expect(result.id, 'trans-1');
        expect(result.productId, 'prod-1');
        expect(result.type, StockTransactionType.addition);
        expect(result.quantity, 50.0);
        expect(result.previousStock, 100.0);
        expect(result.newStock, 150.0);
        expect(result.reason, 'New stock arrival');
        expect(result.timestamp, testDate);
        expect(result.performedBy, 'user-1');
      });

      test('should handle null reason', () {
        // Arrange
        final jsonWithoutReason = Map<String, dynamic>.from(testJson);
        jsonWithoutReason['reason'] = null;

        // Act
        final result = StockTransactionModel.fromJson(jsonWithoutReason);

        // Assert
        expect(result.reason, null);
      });

      test('should handle integer numbers as doubles', () {
        // Arrange
        final jsonWithInts = Map<String, dynamic>.from(testJson);
        jsonWithInts['quantity'] = 50;
        jsonWithInts['previousStock'] = 100;
        jsonWithInts['newStock'] = 150;

        // Act
        final result = StockTransactionModel.fromJson(jsonWithInts);

        // Assert
        expect(result.quantity, 50.0);
        expect(result.previousStock, 100.0);
        expect(result.newStock, 150.0);
      });

      test('should handle all transaction types', () {
        for (final type in StockTransactionType.values) {
          // Arrange
          final json = Map<String, dynamic>.from(testJson);
          json['type'] = type.name;

          // Act
          final result = StockTransactionModel.fromJson(json);

          // Assert
          expect(result.type, type);
        }
      });

      test('should handle decimal values', () {
        // Arrange
        final jsonWithDecimals = Map<String, dynamic>.from(testJson);
        jsonWithDecimals['quantity'] = 25.5;
        jsonWithDecimals['previousStock'] = 100.75;
        jsonWithDecimals['newStock'] = 126.25;

        // Act
        final result = StockTransactionModel.fromJson(jsonWithDecimals);

        // Assert
        expect(result.quantity, 25.5);
        expect(result.previousStock, 100.75);
        expect(result.newStock, 126.25);
      });
    });

    group('toJson', () {
      test('should convert StockTransactionModel to valid JSON', () {
        // Act
        final result = testModel.toJson();

        // Assert
        expect(result['id'], 'trans-1');
        expect(result['productId'], 'prod-1');
        expect(result['type'], 'addition');
        expect(result['quantity'], 50.0);
        expect(result['previousStock'], 100.0);
        expect(result['newStock'], 150.0);
        expect(result['reason'], 'New stock arrival');
        expect(result['timestamp'], isA<Timestamp>());
        expect(result['performedBy'], 'user-1');
      });

      test('should handle null reason', () {
        // Arrange
        final modelWithoutReason = StockTransactionModel(
          id: testModel.id,
          productId: testModel.productId,
          type: testModel.type,
          quantity: testModel.quantity,
          previousStock: testModel.previousStock,
          newStock: testModel.newStock,
          reason: null,
          timestamp: testModel.timestamp,
          performedBy: testModel.performedBy,
        );

        // Act
        final result = modelWithoutReason.toJson();

        // Assert
        expect(result['reason'], null);
      });

      test('should convert timestamp correctly', () {
        // Act
        final result = testModel.toJson();

        // Assert
        final timestamp = result['timestamp'] as Timestamp;
        expect(timestamp.toDate(), testDate);
      });

      test('should convert all transaction types correctly', () {
        for (final type in StockTransactionType.values) {
          // Arrange
          final model = testModel.copyWith(type: type);

          // Act
          final result = model.toJson();

          // Assert
          expect(result['type'], type.name);
        }
      });

      test('should preserve decimal values', () {
        // Arrange
        final modelWithDecimals = testModel.copyWith(
          quantity: 25.5,
          previousStock: 100.75,
          newStock: 126.25,
        );

        // Act
        final result = modelWithDecimals.toJson();

        // Assert
        expect(result['quantity'], 25.5);
        expect(result['previousStock'], 100.75);
        expect(result['newStock'], 126.25);
      });
    });

    group('fromEntity', () {
      test('should create StockTransactionModel from StockTransaction entity', () {
        // Arrange
        final entity = StockTransaction(
          id: 'trans-1',
          productId: 'prod-1',
          type: StockTransactionType.addition,
          quantity: 50.0,
          previousStock: 100.0,
          newStock: 150.0,
          reason: 'New stock arrival',
          timestamp: testDate,
          performedBy: 'user-1',
        );

        // Act
        final result = StockTransactionModel.fromEntity(entity);

        // Assert
        expect(result.id, entity.id);
        expect(result.productId, entity.productId);
        expect(result.type, entity.type);
        expect(result.quantity, entity.quantity);
        expect(result.previousStock, entity.previousStock);
        expect(result.newStock, entity.newStock);
        expect(result.reason, entity.reason);
        expect(result.timestamp, entity.timestamp);
        expect(result.performedBy, entity.performedBy);
      });
    });

    group('toEntity', () {
      test('should convert StockTransactionModel to StockTransaction entity', () {
        // Act
        final result = testModel.toEntity();

        // Assert
        expect(result.id, testModel.id);
        expect(result.productId, testModel.productId);
        expect(result.type, testModel.type);
        expect(result.quantity, testModel.quantity);
        expect(result.previousStock, testModel.previousStock);
        expect(result.newStock, testModel.newStock);
        expect(result.reason, testModel.reason);
        expect(result.timestamp, testModel.timestamp);
        expect(result.performedBy, testModel.performedBy);
      });

      test('should create entity that is not a StockTransactionModel', () {
        // Act
        final result = testModel.toEntity();

        // Assert
        expect(result, isA<StockTransaction>());
        expect(result, isNot(isA<StockTransactionModel>()));
      });
    });

    group('Serialization Round Trip', () {
      test('should maintain data integrity through toJson and fromJson', () {
        // Act
        final json = testModel.toJson();
        final result = StockTransactionModel.fromJson(json);

        // Assert
        expect(result, testModel);
      });

      test('should maintain data integrity through toEntity and fromEntity', () {
        // Act
        final entity = testModel.toEntity();
        final result = StockTransactionModel.fromEntity(entity);

        // Assert
        expect(result, testModel);
      });

      test('should handle complete round trip with null reason', () {
        // Arrange
        final modelWithoutReason = StockTransactionModel(
          id: testModel.id,
          productId: testModel.productId,
          type: testModel.type,
          quantity: testModel.quantity,
          previousStock: testModel.previousStock,
          newStock: testModel.newStock,
          reason: null,
          timestamp: testModel.timestamp,
          performedBy: testModel.performedBy,
        );

        // Act
        final json = modelWithoutReason.toJson();
        final result = StockTransactionModel.fromJson(json);

        // Assert
        expect(result, modelWithoutReason);
        expect(result.reason, null);
      });
    });

    group('Transaction Types', () {
      test('should correctly serialize addition transaction', () {
        // Arrange
        final addition = testModel.copyWith(
          type: StockTransactionType.addition,
          quantity: 50.0,
          previousStock: 100.0,
          newStock: 150.0,
        );

        // Act
        final json = addition.toJson();
        final result = StockTransactionModel.fromJson(json);

        // Assert
        expect(result.type, StockTransactionType.addition);
        expect(result, addition);
      });

      test('should correctly serialize sale transaction', () {
        // Arrange
        final sale = testModel.copyWith(
          type: StockTransactionType.sale,
          quantity: 30.0,
          previousStock: 100.0,
          newStock: 70.0,
        );

        // Act
        final json = sale.toJson();
        final result = StockTransactionModel.fromJson(json);

        // Assert
        expect(result.type, StockTransactionType.sale);
        expect(result, sale);
      });

      test('should correctly serialize adjustment transaction', () {
        // Arrange
        final adjustment = testModel.copyWith(
          type: StockTransactionType.adjustment,
          quantity: 0.0,
          previousStock: 100.0,
          newStock: 95.0,
          reason: 'Damaged items removed',
        );

        // Act
        final json = adjustment.toJson();
        final result = StockTransactionModel.fromJson(json);

        // Assert
        expect(result.type, StockTransactionType.adjustment);
        expect(result, adjustment);
      });
    });
  });
}
