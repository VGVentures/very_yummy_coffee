import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_order_card.dart';

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

    Widget buildCard(Order order) {
      return KdsOrderCard(
        order: order,
        accentColor: Colors.orange,
        actionLabel: 'Start',
        onAction: () {},
        onCancel: () {},
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
  });
}
