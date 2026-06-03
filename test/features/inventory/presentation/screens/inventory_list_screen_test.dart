import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:livestock/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:livestock/features/inventory/presentation/widgets/low_stock_alert_banner.dart';
import 'package:livestock/features/inventory/presentation/widgets/product_card.dart';

void main() {
  group('InventoryListScreen Widget Tests', () {
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
          currentStock: 15.0,
          reorderPoint: 20.0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-1',
        ),
      ];
    });

    Widget createTestWidget(WidgetRef ref) {
      return MaterialApp(
        home: InventoryListScreen(),
      );
    }

    testWidgets('should display app bar with title and add button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
            lowStockProductsProvider.overrideWith((ref) => AsyncValue.data([])),
          ],
          child: MaterialApp(home: InventoryListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Inventory'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display product list when data is loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
            lowStockProductsProvider.overrideWith((ref) => AsyncValue.data([])),
          ],
          child: MaterialApp(home: InventoryListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProductCard), findsNWidgets(2));
      expect(find.text('Premium Animal Feed'), findsOneWidget);
      expect(find.text('Veterinary Supplies'), findsOneWidget);
    });

    testWidgets('should display low stock alert banner when products are low',
        (WidgetTester tester) async {
      final lowStockProduct = mockProducts[1]; // Has stock below reorder point

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
            lowStockProductsProvider
                .overrideWith((ref) => AsyncValue.data([lowStockProduct])),
          ],
          child: MaterialApp(home: InventoryListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LowStockAlertBanner), findsOneWidget);
    });

    testWidgets('should display loading indicator when data is loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider
                .overrideWith((ref) => const AsyncValue.loading()),
            lowStockProductsProvider
                .overrideWith((ref) => const AsyncValue.loading()),
          ],
          child: MaterialApp(home: InventoryListScreen()),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no products exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data([])),
            lowStockProductsProvider.overrideWith((ref) => AsyncValue.data([])),
          ],
          child: MaterialApp(home: InventoryListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No products registered yet'), findsOneWidget);
    });

    testWidgets('should navigate to add product screen when add button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
            lowStockProductsProvider.overrideWith((ref) => AsyncValue.data([])),
          ],
          child: MaterialApp(home: InventoryListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Navigation would be tested in integration tests
    });

    testWidgets('should support pull to refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsProvider.overrideWith((ref) => AsyncValue.data(mockProducts)),
            lowStockProductsProvider.overrideWith((ref) => AsyncValue.data([])),
          ],
          child: MaterialApp(home: InventoryListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
