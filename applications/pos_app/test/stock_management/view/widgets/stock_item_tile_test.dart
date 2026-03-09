import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/view/widgets/stock_item_tile.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('StockItemTile', () {
    testWidgets('renders item name and price', (tester) async {
      await tester.pumpApp(
        StockItemTile(
          name: 'Latte',
          price: 550,
          available: true,
          onToggled: (_) {},
        ),
      );

      expect(find.text('Latte'), findsOneWidget);
      expect(find.text(r'$5.50'), findsOneWidget);
    });

    testWidgets('renders switch in on state when available', (tester) async {
      await tester.pumpApp(
        StockItemTile(
          name: 'Latte',
          price: 550,
          available: true,
          onToggled: (_) {},
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('renders switch in off state when unavailable', (
      tester,
    ) async {
      await tester.pumpApp(
        StockItemTile(
          name: 'Mocha',
          price: 600,
          available: false,
          onToggled: (_) {},
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('calls onToggled when switch is tapped', (tester) async {
      bool? toggledValue;
      await tester.pumpApp(
        StockItemTile(
          name: 'Latte',
          price: 550,
          available: true,
          onToggled: (value) => toggledValue = value,
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(toggledValue, isFalse);
    });
  });
}
