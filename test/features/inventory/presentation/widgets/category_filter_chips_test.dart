import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/widgets/category_filter_chips.dart';

void main() {
  group('CategoryFilterChips Widget Tests', () {
    testWidgets('should display all category chips including "All"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChips(
              selectedCategory: null,
              onCategorySelected: (category) {},
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Animal Feed'), findsOneWidget);
      expect(find.text('Veterinary Supplies'), findsOneWidget);
      expect(find.text('Farm Equipment'), findsOneWidget);
      expect(find.text('Seeds'), findsOneWidget);
      expect(find.text('Fertilizers'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('should highlight selected chip',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChips(
              selectedCategory: ProductCategory.animalFeed,
              onCategorySelected: (category) {},
            ),
          ),
        ),
      );

      // Find the Animal Feed chip
      final animalFeedChip = find.ancestor(
        of: find.text('Animal Feed'),
        matching: find.byType(FilterChip),
      );

      expect(animalFeedChip, findsOneWidget);

      final chip = tester.widget<FilterChip>(animalFeedChip);
      expect(chip.selected, true);
    });

    testWidgets('should highlight "All" chip when no category is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChips(
              selectedCategory: null,
              onCategorySelected: (category) {},
            ),
          ),
        ),
      );

      final allChip = find.ancestor(
        of: find.text('All'),
        matching: find.byType(FilterChip),
      );

      expect(allChip, findsOneWidget);

      final chip = tester.widget<FilterChip>(allChip);
      expect(chip.selected, true);
    });

    testWidgets('should call onCategorySelected when chip is tapped',
        (WidgetTester tester) async {
      ProductCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChips(
              selectedCategory: null,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Animal Feed'));
      await tester.pumpAndSettle();

      expect(selectedCategory, ProductCategory.animalFeed);
    });

    testWidgets('should call onCategorySelected with null when "All" is tapped',
        (WidgetTester tester) async {
      ProductCategory? selectedCategory = ProductCategory.animalFeed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChips(
              selectedCategory: ProductCategory.animalFeed,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(selectedCategory, null);
    });

    testWidgets('should be horizontally scrollable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChips(
              selectedCategory: null,
              onCategorySelected: (category) {},
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });

    testWidgets('should display chips in a row',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChips(
              selectedCategory: null,
              onCategorySelected: (category) {},
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(7)); // All + 6 categories
    });

    testWidgets('should update selection when different chip is tapped',
        (WidgetTester tester) async {
      ProductCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CategoryFilterChips(
                  selectedCategory: selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially "All" should be selected
      var allChip = find.ancestor(
        of: find.text('All'),
        matching: find.byType(FilterChip),
      );
      expect((tester.widget<FilterChip>(allChip)).selected, true);

      // Tap Animal Feed
      await tester.tap(find.text('Animal Feed'));
      await tester.pumpAndSettle();

      // Animal Feed should now be selected
      final animalFeedChip = find.ancestor(
        of: find.text('Animal Feed'),
        matching: find.byType(FilterChip),
      );
      expect((tester.widget<FilterChip>(animalFeedChip)).selected, true);

      // All should no longer be selected
      allChip = find.ancestor(
        of: find.text('All'),
        matching: find.byType(FilterChip),
      );
      expect((tester.widget<FilterChip>(allChip)).selected, false);
    });
  });
}
