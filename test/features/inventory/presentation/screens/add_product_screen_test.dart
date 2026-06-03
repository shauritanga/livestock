import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/screens/add_product_screen.dart';

void main() {
  group('AddProductScreen Widget Tests', () {
    testWidgets('should display all required form fields for new product',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddProductScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for form fields
      expect(find.text('Product Name'), findsOneWidget);
      expect(find.text('SKU'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Unit of Measure'), findsOneWidget);
      expect(find.text('Unit Price'), findsOneWidget);
      expect(find.text('Reorder Point'), findsOneWidget);
      expect(find.text('Initial Stock'), findsOneWidget);
    });

    testWidgets('should display edit mode fields when editing existing product',
        (WidgetTester tester) async {
      final existingProduct = Product(
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AddProductScreen(product: existingProduct),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show Edit Product title
      expect(find.text('Edit Product'), findsOneWidget);
      
      // Should not show Initial Stock field in edit mode
      expect(find.text('Initial Stock'), findsNothing);
      
      // Should show Active Status toggle
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('should validate required fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddProductScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to save without filling fields
      final saveButton = find.byIcon(Icons.check);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter product name'), findsOneWidget);
      expect(find.text('Please enter SKU'), findsOneWidget);
    });

    testWidgets('should validate positive numbers for price and quantities',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddProductScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative price
      final priceField = find.widgetWithText(TextFormField, 'Unit Price');
      await tester.enterText(priceField, '-10');
      await tester.pumpAndSettle();

      // Try to save
      final saveButton = find.byIcon(Icons.check);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Price must be positive'), findsOneWidget);
    });

    testWidgets('should pre-fill form fields when editing product',
        (WidgetTester tester) async {
      final existingProduct = Product(
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AddProductScreen(product: existingProduct),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check pre-filled values
      expect(find.text('Premium Animal Feed'), findsOneWidget);
      expect(find.text('FEED-001'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);
    });

    testWidgets('should display category dropdown with all categories',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddProductScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap category dropdown
      final categoryDropdown = find.text('Category');
      expect(categoryDropdown, findsOneWidget);

      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();

      // Should show all category options
      expect(find.text('Animal Feed'), findsOneWidget);
      expect(find.text('Veterinary Supplies'), findsOneWidget);
      expect(find.text('Farm Equipment'), findsOneWidget);
      expect(find.text('Seeds'), findsOneWidget);
      expect(find.text('Fertilizers'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('should show save button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddProductScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
