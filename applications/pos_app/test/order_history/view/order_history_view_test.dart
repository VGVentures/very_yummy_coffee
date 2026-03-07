import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_history/order_history.dart';

import '../../helpers/pump_app.dart';

class _MockOrderHistoryBloc
    extends MockBloc<OrderHistoryEvent, OrderHistoryState>
    implements OrderHistoryBloc {}

const _testItem = LineItem(id: 'li-1', name: 'Latte', price: 450);

const _pendingOrder = Order(
  id: 'order-1111',
  items: [_testItem],
  status: OrderStatus.pending,
);

final _activeOrder = Order(
  id: 'order-2222',
  items: const [_testItem],
  status: OrderStatus.submitted,
  submittedAt: DateTime(2026, 3, 1, 10),
);

void main() {
  group('OrderHistoryView', () {
    late OrderHistoryBloc orderHistoryBloc;

    setUp(() {
      orderHistoryBloc = _MockOrderHistoryBloc();
    });

    void setLandscapeSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Widget buildSubject() => BlocProvider<OrderHistoryBloc>.value(
      value: orderHistoryBloc,
      child: const OrderHistoryView(),
    );

    testWidgets('shows loading indicator when status is loading', (
      tester,
    ) async {
      setLandscapeSize(tester);
      when(() => orderHistoryBloc.state).thenReturn(
        const OrderHistoryState(),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when status is failure', (tester) async {
      setLandscapeSize(tester);
      when(() => orderHistoryBloc.state).thenReturn(
        const OrderHistoryState(status: OrderHistoryStatus.failure),
      );

      await tester.pumpApp(buildSubject());

      expect(find.text('Unable to load menu'), findsOneWidget);
    });

    testWidgets('renders Pending section title', (tester) async {
      setLandscapeSize(tester);
      when(() => orderHistoryBloc.state).thenReturn(
        const OrderHistoryState(status: OrderHistoryStatus.success),
      );

      await tester.pumpApp(buildSubject());

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders pending cards with Opacity', (tester) async {
      setLandscapeSize(tester);
      when(() => orderHistoryBloc.state).thenReturn(
        const OrderHistoryState(
          status: OrderHistoryStatus.success,
          pendingOrders: [_pendingOrder],
        ),
      );

      await tester.pumpApp(buildSubject());

      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, 0.6);
      expect(find.text(_pendingOrder.orderNumber), findsOneWidget);
    });

    testWidgets('renders both Pending and In Progress sections', (
      tester,
    ) async {
      setLandscapeSize(tester);
      when(() => orderHistoryBloc.state).thenReturn(
        OrderHistoryState(
          status: OrderHistoryStatus.success,
          pendingOrders: const [_pendingOrder],
          activeOrders: [_activeOrder],
        ),
      );

      await tester.pumpApp(buildSubject());

      // "Pending" appears as section title + status chip on the pending card
      expect(find.text('Pending'), findsAtLeast(1));
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text(_pendingOrder.orderNumber), findsOneWidget);
      expect(find.text(_activeOrder.orderNumber), findsOneWidget);
    });
  });
}
