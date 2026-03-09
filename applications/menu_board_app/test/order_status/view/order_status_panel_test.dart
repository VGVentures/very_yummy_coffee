import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/order_status/order_status.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

import '../../helpers/helpers.dart';

class _MockOrderStatusBloc extends MockBloc<OrderStatusEvent, OrderStatusState>
    implements OrderStatusBloc {}

void main() {
  late OrderStatusBloc orderStatusBloc;

  final now = DateTime(2026, 3, 9, 12);
  final earlier = DateTime(2026, 3, 9, 11);

  final inProgressOrder = Order(
    id: 'order-1',
    items: const [LineItem(id: 'li-1', name: 'Latte', price: 550)],
    status: OrderStatus.inProgress,
    customerName: 'Marcus',
    submittedAt: now,
  );

  final readyOrder = Order(
    id: 'order-2',
    items: const [LineItem(id: 'li-2', name: 'Espresso', price: 350)],
    status: OrderStatus.ready,
    customerName: 'Alice',
    submittedAt: earlier,
  );

  final orderWithoutName = Order(
    id: 'abcd-ef12',
    items: const [LineItem(id: 'li-3', name: 'Mocha', price: 600)],
    status: OrderStatus.inProgress,
    submittedAt: now,
  );

  setUp(() {
    orderStatusBloc = _MockOrderStatusBloc();
  });

  group('OrderStatusPanel', () {
    testWidgets('renders Preparing section with in-progress orders', (
      tester,
    ) async {
      when(() => orderStatusBloc.state).thenReturn(
        OrderStatusState(
          status: OrderStatusStatus.success,
          inProgressOrders: [inProgressOrder],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      expect(find.text('Preparing'), findsWidgets);
      expect(find.text('Marcus'), findsOneWidget);
    });

    testWidgets('renders Ready for Pickup section with ready orders', (
      tester,
    ) async {
      when(() => orderStatusBloc.state).thenReturn(
        OrderStatusState(
          status: OrderStatusStatus.success,
          readyOrders: [readyOrder],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      expect(find.text('Ready for Pickup'), findsWidgets);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('hides Preparing section when no in-progress orders', (
      tester,
    ) async {
      when(() => orderStatusBloc.state).thenReturn(
        OrderStatusState(
          status: OrderStatusStatus.success,
          readyOrders: [readyOrder],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      // Only "Ready for Pickup" section headers and status labels visible.
      expect(find.text('Ready for Pickup'), findsWidgets);
      // "Preparing" text should not appear at all since there are no
      // in-progress orders.
      expect(find.text('Preparing'), findsNothing);
    });

    testWidgets('hides Ready for Pickup section when no ready orders', (
      tester,
    ) async {
      when(() => orderStatusBloc.state).thenReturn(
        OrderStatusState(
          status: OrderStatusStatus.success,
          inProgressOrders: [inProgressOrder],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      expect(find.text('Preparing'), findsWidgets);
      expect(find.text('Ready for Pickup'), findsNothing);
    });

    testWidgets('shows customer name when available', (tester) async {
      when(() => orderStatusBloc.state).thenReturn(
        OrderStatusState(
          status: OrderStatusStatus.success,
          inProgressOrders: [inProgressOrder],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      expect(find.text('Marcus'), findsOneWidget);
    });

    testWidgets('shows order number when customer name is null', (
      tester,
    ) async {
      when(() => orderStatusBloc.state).thenReturn(
        OrderStatusState(
          status: OrderStatusStatus.success,
          inProgressOrders: [orderWithoutName],
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      // order id 'abcd-ef12' => '#EF12'
      expect(find.text('#EF12'), findsOneWidget);
    });

    testWidgets('shows +X more indicator when orders exceed cap', (
      tester,
    ) async {
      final manyOrders = List.generate(
        7,
        (i) => Order(
          id: 'order-$i',
          items: const [LineItem(id: 'li', name: 'Latte', price: 550)],
          status: OrderStatus.inProgress,
          customerName: 'Customer $i',
          submittedAt: DateTime(2026, 3, 9, i),
        ),
      );

      when(() => orderStatusBloc.state).thenReturn(
        OrderStatusState(
          status: OrderStatusStatus.success,
          inProgressOrders: manyOrders,
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      expect(find.text('+2 more'), findsOneWidget);
      // Only 5 OrderStatusCards visible.
      expect(find.byType(OrderStatusCard), findsNWidgets(5));
    });

    testWidgets('renders loading state without errors', (tester) async {
      when(() => orderStatusBloc.state).thenReturn(
        const OrderStatusState(status: OrderStatusStatus.loading),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: orderStatusBloc,
          child: const OrderStatusPanel(),
        ),
      );

      // Panel renders but with no sections.
      expect(find.byType(OrderStatusPanel), findsOneWidget);
      expect(find.text('Preparing'), findsNothing);
      expect(find.text('Ready for Pickup'), findsNothing);
    });
  });
}
