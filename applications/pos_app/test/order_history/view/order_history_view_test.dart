import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_history/order_history.dart';

import '../../helpers/go_router.dart';
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

final _inProgressOrder = Order(
  id: 'order-3333',
  items: const [_testItem],
  status: OrderStatus.inProgress,
  submittedAt: DateTime(2026, 3, 1, 10),
);

final _readyOrder = Order(
  id: 'order-4444',
  items: const [_testItem],
  status: OrderStatus.ready,
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

    testWidgets('renders pending cards at full opacity with edit hint', (
      tester,
    ) async {
      setLandscapeSize(tester);
      when(() => orderHistoryBloc.state).thenReturn(
        const OrderHistoryState(
          status: OrderHistoryStatus.success,
          pendingOrders: [_pendingOrder],
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(Opacity), findsNothing);
      expect(find.text(_pendingOrder.orderNumber), findsOneWidget);
      expect(find.text('Tap to edit'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets(
      'tapping pending card dispatches OrderHistoryPendingOrderResumeRequested',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          const OrderHistoryState(
            status: OrderHistoryStatus.success,
            pendingOrders: [_pendingOrder],
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.tap(find.byType(InkWell).first);

        verify(
          () => orderHistoryBloc.add(
            OrderHistoryPendingOrderResumeRequested(_pendingOrder.id),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'tapping pending card navigates to /ordering',
      (tester) async {
        setLandscapeSize(tester);
        final goRouter = MockGoRouter();
        when(() => goRouter.go(any())).thenReturn(null);
        when(() => orderHistoryBloc.state).thenReturn(
          const OrderHistoryState(
            status: OrderHistoryStatus.success,
            pendingOrders: [_pendingOrder],
          ),
        );

        await tester.pumpApp(buildSubject(), goRouter: goRouter);
        await tester.tap(find.byType(InkWell).first);

        verify(() => goRouter.go('/ordering')).called(1);
      },
    );

    testWidgets(
      'non-pending order cards are not wrapped in InkWell for editing',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_activeOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('Tap to edit'), findsNothing);
      },
    );

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

    testWidgets(
      'submitted order card shows Start and Cancel buttons',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_activeOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('Start'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      },
    );

    testWidgets(
      'in-progress order card shows Mark Ready and Cancel buttons',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_inProgressOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('Mark Ready'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      },
    );

    testWidgets(
      'ready order card shows Complete button but no Cancel',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_readyOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('Complete'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);
      },
    );

    testWidgets(
      'pending order card shows no action buttons',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          const OrderHistoryState(
            status: OrderHistoryStatus.success,
            pendingOrders: [_pendingOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('Start'), findsNothing);
        expect(find.text('Mark Ready'), findsNothing);
        expect(find.text('Complete'), findsNothing);
        expect(find.text('Cancel'), findsNothing);
      },
    );

    testWidgets(
      'tap Mark Ready dispatches OrderHistoryOrderMarkedReady',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_inProgressOrder],
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Mark Ready'));

        verify(
          () => orderHistoryBloc.add(
            OrderHistoryOrderMarkedReady(_inProgressOrder.id),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'tap Complete dispatches OrderHistoryOrderCompleted',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_readyOrder],
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Complete'));

        verify(
          () => orderHistoryBloc.add(
            OrderHistoryOrderCompleted(_readyOrder.id),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'tap Start dispatches OrderHistoryOrderStarted',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_activeOrder],
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Start'));

        verify(
          () => orderHistoryBloc.add(
            OrderHistoryOrderStarted(_activeOrder.id),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'tap Cancel opens confirmation dialog',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_activeOrder],
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Cancel Order?'), findsOneWidget);
      },
    );

    testWidgets(
      'confirm cancel dispatches OrderHistoryOrderCancelled',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_activeOrder],
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yes, Cancel'));
        await tester.pumpAndSettle();

        verify(
          () => orderHistoryBloc.add(
            OrderHistoryOrderCancelled(_activeOrder.id),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'dismiss cancel dialog does not dispatch event',
      (tester) async {
        setLandscapeSize(tester);
        when(() => orderHistoryBloc.state).thenReturn(
          OrderHistoryState(
            status: OrderHistoryStatus.success,
            activeOrders: [_activeOrder],
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();

        verifyNever(
          () => orderHistoryBloc.add(
            OrderHistoryOrderCancelled(_activeOrder.id),
          ),
        );
      },
    );
  });
}
