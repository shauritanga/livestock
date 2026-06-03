import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/widgets/product_search_bar.dart';

void main() {
  group('ProductSearchBar Widget Tests', () {
    testWidgets('should display search input field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {},
              onCategoryChanged: (category) {},
              onStockStatusChanged: (status) {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should call onSearchChanged when text is entered',
        (WidgetTester tester) async {
      String? searchQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {
                searchQuery = query;
              },
              onCategoryChanged: (category) {},
              onStockStatusChanged: (status) {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Animal Feed');
      await tester.pump(const Duration(milliseconds: 350)); // Wait for debounce

      expect(searchQuery, 'Animal Feed');
    });

    testWidgets('should debounce search input',
        (WidgetTester tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {
                callCount++;
              },
              onCategoryChanged: (category) {},
              onStockStatusChanged: (status) {},
            ),
          ),
        ),
      );

      // Type multiple characters quickly
      await tester.enterText(find.byType(TextField), 'A');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'An');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'Ani');
      await tester.pump(const Duration(milliseconds: 350));

      // Should only call once after debounce period
      expect(callCount, 1);
    });

    testWidgets('should display category filter dropdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {},
              onCategoryChanged: (category) {},
              onStockStatusChanged: (status) {},
            ),
          ),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
      expect(find.byType(DropdownButton<ProductCategory?>), findsOneWidget);
    });

    testWidgets('should display stock status filter dropdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {},
              onCategoryChanged: (category) {},
              onStockStatusChanged: (status) {},
            ),
          ),
        ),
      );

      expect(find.text('Stock Status'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsWidgets);
    });

    testWidgets('should call onCategoryChanged when category is selected',
        (WidgetTester tester) async {
      ProductCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {},
              onCategoryChanged: (category) {
                selectedCategory = category;
              },
              onStockStatusChanged: (status) {},
            ),
          ),
        ),
      );

      // Tap category dropdown
      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();

      // Select a category
      await tester.tap(find.text('Animal Feed').last);
      await tester.pumpAndSettle();

      expect(selectedCategory, ProductCategory.animalFeed);
    });

    testWidgets('should display clear filters button when filters are applied',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {},
              onCategoryChanged: (category) {},
              onStockStatusChanged: (status) {},
              initialCategory: ProductCategory.animalFeed,
            ),
          ),
        ),
      );

      expect(find.text('Clear Filters'), findsOneWidget);
    });

    testWidgets('should clear all filters when clear button is pressed',
        (WidgetTester tester) async {
      bool filtersCleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {},
              onCategoryChanged: (category) {
                if (category == null) filtersCleared = true;
              },
              onStockStatusChanged: (status) {},
              initialCategory: ProductCategory.animalFeed,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      expect(filtersCleared, true);
    });

    testWidgets('should display result count when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSearchBar(
              onSearchChanged: (query) {},
              onCategoryChanged: (category) {},
              onStockStatusChanged: (status) {},
              resultCount: 15,
            ),
          ),
        ),
      );

      expect(find.text('15 results'), findsOneWidget);
    });
  });
}
