import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';
import 'package:livestock/features/inventory/presentation/widgets/sale_card.dart';

void main() {
  group('SaleCard Widget Tests', () {
    late SaleTransaction mockSale;

    setUp(() {
      mockSale = SaleTransaction(
        id: 'sale-1',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        productName: 'Premium Animal Feed',
        quantity: 25.0,
        unitPrice: 150.0,
        totalAmount: 3750.0,
        customerName: 'John Doe',
        notes: 'Bulk purchase',
        timestamp: DateTime(2024, 1, 15, 10, 30),
        processedBy: 'user-1',
        isSynced: true,
      );
    });

    testWidgets('should display product name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: mockSale,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Premium Animal Feed'), findsOneWidget);
    });

    testWidgets('should display quantity with unit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: mockSale,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('25.0'), findsOneWidget);
    });

    testWidgets('should display total amount prominently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: mockSale,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('3750.0'), findsOneWidget);
    });

    testWidgets('should display customer name when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: mockSale,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should display date and time',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: mockSale,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should display formatted date
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: mockSale,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SaleCard));
      await tester.pumpAndSettle();

      expect(wasTapped, true);
    });

    testWidgets('should display card with elevation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: mockSale,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle sale without customer name',
        (WidgetTester tester) async {
      final saleWithoutCustomer = SaleTransaction(
        id: 'sale-2',
        cooperativeId: 'coop-1',
        productId: 'prod-1',
        productName: 'Test Product',
        quantity: 10.0,
        unitPrice: 50.0,
        totalAmount: 500.0,
        timestamp: DateTime.now(),
        processedBy: 'user-1',
        isSynced: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: saleWithoutCustomer,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should not crash and should display product name
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('should show sync status indicator for unsynced sales',
        (WidgetTester tester) async {
      final unsyncedSale = mockSale.copyWith(isSynced: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaleCard(
              sale: unsyncedSale,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should show some indicator for unsynced status
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });
  });
}
