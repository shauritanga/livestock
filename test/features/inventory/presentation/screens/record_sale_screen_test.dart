import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:livestock/features/inventory/presentation/screens/record_sale_screen.dart';

void main() {
  group('RecordSaleScreen Widget Tests', () {
    late List<Product> mockProducts;

    setUp(() {
      mockProducts = [
        Product(
          id: 'prod-1',
          cooperativeId: 'coop-1',
          sku: 'FEED-001',
          name: 'Premium Animal Feed',
          category: ProductCategory.animalFeed,
          unitOfMeasure: 'kg',
          unitPrice: 150.0,
          currentStock: 100.0,
          reorderPoint: 50.0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-1',
        ),
        Product(
          id: 'prod-2',
          cooperativeId: 'coop-1',
          sku: 'VET-001',
          name: 'Veterinary Supplies',
          category: ProductCategory.veterinarySupplies,
          unitOfMeasure: 'pieces',
          unitPrice: 50.0,
          currentStock: 0.0, // Out of stock
          reorderPoint: 20.0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-1',
        ),
      ];
    });

    testWidgets('should display product search bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Search product...'), findsOneWidget);
    });

    testWidgets('should display product list with available stock',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Premium Animal Feed'), findsOneWidget);
      expect(find.text('100.0 kg available'), findsOneWidget);
    });

    testWidgets('should disable out-of-stock products',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Out of stock product should be visible but disabled
      expect(find.text('Veterinary Supplies'), findsOneWidget);
      expect(find.text('Out of stock'), findsOneWidget);
    });

    testWidgets('should display sale details form after product selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Select a product
      await tester.tap(find.text('Premium Animal Feed'));
      await tester.pumpAndSettle();

      // Should show sale details form
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Unit Price'), findsOneWidget);
      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('should validate quantity does not exceed available stock',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Select a product
      await tester.tap(find.text('Premium Animal Feed'));
      await tester.pumpAndSettle();

      // Enter quantity exceeding available stock
      final quantityField = find.widgetWithText(TextFormField, 'Quantity');
      await tester.enterText(quantityField, '150'); // More than 100 available
      await tester.pumpAndSettle();

      // Try to save
      final saveButton = find.text('Record Sale');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Quantity exceeds available stock'), findsOneWidget);
    });

    testWidgets('should calculate total amount in real-time',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Select a product
      await tester.tap(find.text('Premium Animal Feed'));
      await tester.pumpAndSettle();

      // Enter quantity
      final quantityField = find.widgetWithText(TextFormField, 'Quantity');
      await tester.enterText(quantityField, '10');
      await tester.pumpAndSettle();

      // Should show calculated total (10 × 150 = 1500)
      expect(find.text('1500.0'), findsOneWidget);
    });

    testWidgets('should show save and cancel buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Select a product first
      await tester.tap(find.text('Premium Animal Feed'));
      await tester.pumpAndSettle();

      expect(find.text('Record Sale'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should pre-fill unit price from product',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(home: RecordSaleScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Select a product
      await tester.tap(find.text('Premium Animal Feed'));
      await tester.pumpAndSettle();

      // Unit price should be pre-filled with product's unit price
      expect(find.text('150.0'), findsOneWidget);
    });
  });
}
