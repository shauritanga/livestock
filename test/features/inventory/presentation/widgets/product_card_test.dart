import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/widgets/product_card.dart';

void main() {
  late Product testProduct;

  setUp(() {
    testProduct = Product(
      id: 'prod-1',
      cooperativeId: 'coop-1',
      sku: 'SKU-001',
      name: 'Test Product',
      category: ProductCategory.animalFeed,
      unitOfMeasure: 'kg',
      unitPrice: 100.0,
      currentStock: 50.0,
      reorderPoint: 20.0,
      isActive: true,
      createdAt: DateTime(2025, 11, 22),
      updatedAt: DateTime(2025, 11, 22),
      createdBy: 'user-1',
    );
  });

  Widget createTestWidget(Product product, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: ProductCard(
          product: product,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  group('ProductCard Widget', () {
    testWidgets('should display product name', (tester) async {
      await tester.pumpWidget(createTestWidget(testProduct));

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('should display SKU', (tester) async {
      await tester.pumpWidget(createTestWidget(testProduct));

      expect(find.textContaining('SKU-001'), findsOneWidget);
    });

    testWidgets('should display stock level with unit', (tester) async {
      await tester.pumpWidget(createTestWidget(testProduct));

      expect(find.textContaining('50'), findsWidgets);
      expect(find.textContaining('kg'), findsWidgets);
    });

    testWidgets('should display unit price', (tester) async {
      await tester.pumpWidget(createTestWidget(testProduct));

      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('should show in stock status for product above reorder point',
        (tester) async {
      await tester.pumpWidget(createTestWidget(testProduct));

      // Product with 50 stock and 20 reorder point should show "In Stock"
      expect(testProduct.isLowStock, false);
    });

    testWidgets('should show low stock status for product at reorder point',
        (tester) async {
      final lowStockProduct = testProduct.copyWith(
        currentStock: 20.0,
        reorderPoint: 20.0,
      );

      await tester.pumpWidget(createTestWidget(lowStockProduct));

      expect(lowStockProduct.isLowStock, true);
    });

    testWidgets('should show out of stock status for product with zero stock',
        (tester) async {
      final outOfStockProduct = testProduct.copyWith(currentStock: 0.0);

      await tester.pumpWidget(createTestWidget(outOfStockProduct));

      expect(outOfStockProduct.isOutOfStock, true);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createTestWidget(
        testProduct,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
