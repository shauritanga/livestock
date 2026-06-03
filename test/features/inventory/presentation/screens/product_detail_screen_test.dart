import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:livestock/features/inventory/presentation/screens/product_detail_screen.dart';

void main() {
  group('ProductDetailScreen Widget Tests', () {
    late Product mockProduct;

    setUp(() {
      mockProduct = Product(
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
      );
    });

    testWidgets('should display product name in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(mockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Premium Animal Feed'), findsOneWidget);
    });

    testWidgets('should display product info card with details',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(mockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('FEED-001'), findsOneWidget);
      expect(find.text('Animal Feed'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('should display stock summary card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(mockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('100.0 kg'), findsOneWidget);
      expect(find.text('Reorder Point: 50.0'), findsOneWidget);
    });

    testWidgets('should display quick action buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(mockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Stock'), findsOneWidget);
      expect(find.text('Adjust Stock'), findsOneWidget);
    });

    testWidgets('should display pricing information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(mockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unit Price'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);
      
      // Inventory value = 100 × 150 = 15000
      expect(find.text('Inventory Value'), findsOneWidget);
      expect(find.text('15000.0'), findsOneWidget);
    });

    testWidgets('should display recent transactions section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(mockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('should display edit button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(mockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should show low stock indicator when stock is low',
        (WidgetTester tester) async {
      final lowStockProduct = mockProduct.copyWith(currentStock: 30.0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(lowStockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Low Stock'), findsOneWidget);
    });

    testWidgets('should show out of stock indicator when stock is zero',
        (WidgetTester tester) async {
      final outOfStockProduct = mockProduct.copyWith(currentStock: 0.0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productByIdProvider('prod-1')
                .overrideWith((ref) => AsyncValue.data(outOfStockProduct)),
          ],
          child: MaterialApp(
            home: ProductDetailScreen(productId: 'prod-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Out of Stock'), findsOneWidget);
    });
  });
}
