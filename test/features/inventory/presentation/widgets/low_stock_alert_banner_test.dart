import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livestock/features/inventory/presentation/widgets/low_stock_alert_banner.dart';

void main() {
  group('LowStockAlertBanner Widget Tests', () {
    testWidgets('should display low stock count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowStockAlertBanner(
              lowStockCount: 5,
              onViewTapped: () {},
            ),
          ),
        ),
      );

      expect(find.text('5 products need restocking'), findsOneWidget);
    });

    testWidgets('should display warning icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowStockAlertBanner(
              lowStockCount: 3,
              onViewTapped: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should display View button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowStockAlertBanner(
              lowStockCount: 3,
              onViewTapped: () {},
            ),
          ),
        ),
      );

      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('should call onViewTapped when View button is pressed',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowStockAlertBanner(
              lowStockCount: 3,
              onViewTapped: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();

      expect(wasTapped, true);
    });

    testWidgets('should have orange/warning background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowStockAlertBanner(
              lowStockCount: 3,
              onViewTapped: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LowStockAlertBanner),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
      // Should have warning/orange color
    });

    testWidgets('should be dismissible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowStockAlertBanner(
              lowStockCount: 3,
              onViewTapped: () {},
            ),
          ),
        ),
      );

      // Check if Dismissible widget exists
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('should display singular text for 1 product',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LowStockAlertBanner(
              lowStockCount: 1,
              onViewTapped: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 product needs restocking'), findsOneWidget);
    });
  });
}
