import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  Widget buildSubject({
    required String itemName,
    int quantity = 1,
    List<String> modifierLabels = const [],
    int? totalCents,
    String? priceDisplayText,
    String? outOfStockLabel,
    VoidCallback? onRemove,
  }) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: OrderLineItemRow(
          itemName: itemName,
          quantity: quantity,
          modifierLabels: modifierLabels,
          totalCents: totalCents,
          priceDisplayText: priceDisplayText,
          outOfStockLabel: outOfStockLabel,
          onRemove: onRemove,
        ),
      ),
    );
  }

  group('OrderLineItemRow', () {
    testWidgets('renders item name', (tester) async {
      await tester.pumpWidget(
        buildSubject(itemName: 'Espresso', totalCents: 450),
      );

      expect(find.text('Espresso'), findsOneWidget);
    });

    testWidgets('shows price when totalCents is set', (tester) async {
      await tester.pumpWidget(
        buildSubject(itemName: 'Latte', totalCents: 550),
      );

      expect(find.text(r'$5.50'), findsOneWidget);
    });

    testWidgets('hides price when totalCents is null', (tester) async {
      await tester.pumpWidget(
        buildSubject(itemName: 'Latte'),
      );

      expect(find.text(r'$'), findsNothing);
    });

    testWidgets('shows modifier chips when modifierLabels is non-empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          itemName: 'Latte',
          modifierLabels: ['Oat Milk', 'Grande'],
          totalCents: 600,
        ),
      );

      expect(find.text('Oat Milk'), findsOneWidget);
      expect(find.text('Grande'), findsOneWidget);
    });

    testWidgets('hides modifier row when modifierLabels is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(itemName: 'Espresso', totalCents: 450),
      );

      expect(find.byType(ModifierSummaryChips), findsNothing);
    });

    testWidgets('shows Qty when quantity > 1', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          itemName: 'Espresso',
          quantity: 2,
          totalCents: 900,
        ),
      );

      expect(find.text('Qty: 2'), findsOneWidget);
    });

    testWidgets('does not show Qty when quantity is 1', (tester) async {
      await tester.pumpWidget(
        buildSubject(itemName: 'Espresso', totalCents: 450),
      );

      expect(find.text('Qty: 1'), findsNothing);
    });

    testWidgets('shows remove icon when onRemove is set', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          itemName: 'Espresso',
          totalCents: 450,
          onRemove: () {},
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not show remove icon when onRemove is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(itemName: 'Espresso', totalCents: 450),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows out-of-stock badge when outOfStockLabel is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          itemName: 'Latte',
          totalCents: 550,
          outOfStockLabel: 'Unavailable',
        ),
      );

      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.byType(OutOfStockBadge), findsOneWidget);
    });

    testWidgets('shows priceDisplayText when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          itemName: 'Latte',
          priceDisplayText: '€4,50',
        ),
      );

      expect(find.text('€4,50'), findsOneWidget);
    });

    testWidgets('tap remove icon invokes onRemove', (tester) async {
      var removeCalled = false;
      await tester.pumpWidget(
        buildSubject(
          itemName: 'Espresso',
          totalCents: 450,
          onRemove: () => removeCalled = true,
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(removeCalled, isTrue);
    });
  });
}
