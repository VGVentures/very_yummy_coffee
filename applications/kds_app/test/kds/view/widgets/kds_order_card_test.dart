import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_elapsed_widget.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_order_card.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('KdsOrderCard', () {
    const baseOrder = Order(
      id: 'aaaa-bbbb-cccc-dddd',
      items: [
        LineItem(id: 'li-1', name: 'Latte', price: 500),
      ],
      status: OrderStatus.submitted,
    );

    Widget buildCard(
      Order order, {
      Color? accentColor,
      String? actionLabel = 'Start',
      VoidCallback? onAction = _noop,
      VoidCallback? onCancel = _noop,
    }) {
      return Builder(
        builder: (context) => KdsOrderCard(
          order: order,
          accentColor: accentColor ?? context.colors.primary,
          actionLabel: actionLabel,
          onAction: onAction,
          onCancel: onCancel,
        ),
      );
    }

    testWidgets('renders customer name when present', (tester) async {
      final order = baseOrder.copyWith(customerName: 'Marcus');
      await tester.pumpApp(buildCard(order));

      expect(find.text('Marcus'), findsOneWidget);
    });

    testWidgets('omits customer name when null', (tester) async {
      await tester.pumpApp(buildCard(baseOrder));

      // Only the order number text and item text should be present
      expect(find.text('Marcus'), findsNothing);
    });

    testWidgets('omits customer name when empty string', (tester) async {
      final order = baseOrder.copyWith(customerName: '');
      await tester.pumpApp(buildCard(order));

      // Empty name should not render an extra Text widget
      // Verify the order number still renders
      expect(find.text(order.orderNumber), findsOneWidget);
    });

    testWidgets(
      'hides action buttons and elapsed widget when callbacks are null',
      (tester) async {
        await tester.pumpApp(
          buildCard(
            baseOrder,
            actionLabel: null,
            onAction: null,
            onCancel: null,
          ),
        );

        expect(find.byType(FilledButton), findsNothing);
        expect(find.byType(TextButton), findsNothing);
        expect(find.byType(KdsElapsedWidget), findsNothing);
      },
    );

    testWidgets(
      'shows action buttons and elapsed widget when callbacks are provided',
      (tester) async {
        await tester.pumpApp(buildCard(baseOrder));

        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
        expect(find.byType(KdsElapsedWidget), findsOneWidget);
      },
    );

    testWidgets('tap action button invokes onAction', (tester) async {
      var actionCalled = false;
      await tester.pumpApp(
        buildCard(baseOrder, onAction: () => actionCalled = true),
      );
      await tester.tap(find.byType(FilledButton));
      expect(actionCalled, isTrue);
    });

    testWidgets('tap cancel button invokes onCancel', (tester) async {
      var cancelCalled = false;
      await tester.pumpApp(
        buildCard(baseOrder, onCancel: () => cancelCalled = true),
      );
      await tester.tap(find.byType(TextButton));
      expect(cancelCalled, isTrue);
    });
  });
}

void _noop() {}
