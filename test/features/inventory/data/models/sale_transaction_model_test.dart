import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/data/models/sale_transaction_model.dart';

void main() {
  group('SaleTransactionModel', () {
    final testDate = DateTime(2024, 1, 1);
    final testTimestamp = Timestamp.fromDate(testDate);

    final testJson = {
      'id': 'sale1',
      'cooperativeId': 'coop1',
      'productId': 'product1',
      'productName': 'Animal Feed',
      'quantity': 10.0,
      'unitPrice': 50.0,
      'totalAmount': 500.0,
      'customerName': 'John Doe',
      'notes': 'Test sale',
      'timestamp': testTimestamp,
      'processedBy': 'user1',
      'isSynced': true,
    };

    final testModel = SaleTransactionModel(
      id: 'sale1',
      cooperativeId: 'coop1',
      productId: 'product1',
      productName: 'Animal Feed',
      quantity: 10.0,
      unitPrice: 50.0,
      totalAmount: 500.0,
      customerName: 'John Doe',
      notes: 'Test sale',
      timestamp: testDate,
      processedBy: 'user1',
      isSynced: true,
    );

    test('should deserialize from JSON correctly', () {
      // Act
      final result = SaleTransactionModel.fromJson(testJson);

      // Assert
      expect(result.id, 'sale1');
      expect(result.cooperativeId, 'coop1');
      expect(result.productId, 'product1');
      expect(result.productName, 'Animal Feed');
      expect(result.quantity, 10.0);
      expect(result.unitPrice, 50.0);
      expect(result.totalAmount, 500.0);
      expect(result.customerName, 'John Doe');
      expect(result.notes, 'Test sale');
      expect(result.processedBy, 'user1');
      expect(result.isSynced, true);
    });

    test('should serialize to JSON correctly', () {
      // Act
      final result = testModel.toJson();

      // Assert
      expect(result['id'], 'sale1');
      expect(result['cooperativeId'], 'coop1');
      expect(result['productId'], 'product1');
      expect(result['productName'], 'Animal Feed');
      expect(result['quantity'], 10.0);
      expect(result['unitPrice'], 50.0);
      expect(result['totalAmount'], 500.0);
      expect(result['customerName'], 'John Doe');
      expect(result['notes'], 'Test sale');
      expect(result['processedBy'], 'user1');
      expect(result['isSynced'], true);
    });

    test('should handle optional fields correctly', () {
      // Arrange
      final jsonWithoutOptionals = {
        'id': 'sale1',
        'cooperativeId': 'coop1',
        'productId': 'product1',
        'productName': 'Animal Feed',
        'quantity': 10.0,
        'unitPrice': 50.0,
        'totalAmount': 500.0,
        'timestamp': testTimestamp,
        'processedBy': 'user1',
        'isSynced': true,
      };

      // Act
      final result = SaleTransactionModel.fromJson(jsonWithoutOptionals);

      // Assert
      expect(result.customerName, null);
      expect(result.notes, null);
    });

    test('should convert to entity correctly', () {
      // Act
      final entity = testModel.toEntity();

      // Assert
      expect(entity.id, testModel.id);
      expect(entity.cooperativeId, testModel.cooperativeId);
      expect(entity.productId, testModel.productId);
      expect(entity.quantity, testModel.quantity);
      expect(entity.totalAmount, testModel.totalAmount);
    });
  });
}
