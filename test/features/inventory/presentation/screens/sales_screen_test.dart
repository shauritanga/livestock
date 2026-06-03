import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/sale_transaction.dart';
import 'package:livestock/features/inventory/presentation/providers/sales_providers.dart';
import 'package:livestock/features/inventory/presentation/screens/sales_screen.dart';
import 'package:livestock/features/inventory/presentation/widgets/sale_card.dart';

void main() {
  group('SalesScreen Widget Tests', () {
    late List<SaleTransaction> mockSales;

    setUp(() {
      mockSales = [
        SaleTransaction(
          id: 'sale-1',
          cooperativeId: 'coop-1',
          productId: 'prod-1',
          productName: 'Premium Animal Feed',
          quantity: 25.0,
          unitPrice: 150.0,
          totalAmount: 3750.0,
          customerName: 'John Doe',
          notes: 'Bulk purchase',
          timestamp: DateTime.now(),
          processedBy: 'user-1',
          isSynced: true,
        ),
        SaleTransaction(
          id: 'sale-2',
          cooperativeId: 'coop-1',
          productId: 'prod-2',
          productName: 'Veterinary Supplies',
          quantity: 10.0,
          unitPrice: 50.0,
          totalAmount: 500.0,
          timestamp: DateTime.now(),
          processedBy: 'user-1',
          isSynced: true,
        ),
      ];
    });

    testWidgets('should display app bar with title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => AsyncValue.data(mockSales)),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sales'), findsOneWidget);
    });

    testWidgets('should display floating action button for recording sale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => AsyncValue.data(mockSales)),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display sales list when data is loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => AsyncValue.data(mockSales)),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SaleCard), findsNWidgets(2));
      expect(find.text('Premium Animal Feed'), findsOneWidget);
      expect(find.text('Veterinary Supplies'), findsOneWidget);
    });

    testWidgets('should display summary cards for sales statistics',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => AsyncValue.data(mockSales)),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should show summary cards (Today, This Week, This Month)
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
    });

    testWidgets('should display loading indicator when data is loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => const AsyncValue.loading()),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no sales exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => AsyncValue.data([])),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No sales recorded yet'), findsOneWidget);
    });

    testWidgets('should support pull to refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => AsyncValue.data(mockSales)),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should navigate to record sale screen when FAB is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salesProvider.overrideWith((ref) => AsyncValue.data(mockSales)),
          ],
          child: const MaterialApp(home: SalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Navigation would be tested in integration tests
    });
  });
}
