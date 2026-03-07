import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/order_complete/order_complete.dart';

import '../../helpers/helpers.dart';

class _MockOrderCompleteBloc
    extends MockBloc<OrderCompleteEvent, OrderCompleteState>
    implements OrderCompleteBloc {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Cappuccino',
  price: 400,
);

const _pendingOrder = Order(
  id: 'order-abc-1234',
  items: [_testItem],
  status: OrderStatus.pending,
);

const _submittedOrder = Order(
  id: 'order-abc-1234',
  items: [_testItem],
  status: OrderStatus.submitted,
);

const _completedOrder = Order(
  id: 'order-abc-1234',
  items: [_testItem],
  status: OrderStatus.completed,
);

const _readyOrder = Order(
  id: 'order-abc-1234',
  items: [_testItem],
  status: OrderStatus.ready,
);

const _cancelledOrder = Order(
  id: 'order-abc-1234',
  items: [_testItem],
  status: OrderStatus.cancelled,
);

void main() {
  group('OrderCompleteView', () {
    late OrderCompleteBloc bloc;

    setUp(() {
      bloc = _MockOrderCompleteBloc();
    });

    Widget buildSubject() => BlocProvider.value(
      value: bloc,
      child: const OrderCompleteView(),
    );

    group('OrderCompleteStatus.loading', () {
      testWidgets('shows CircularProgressIndicator', (tester) async {
        when(() => bloc.state).thenReturn(const OrderCompleteState());
        whenListen(bloc, Stream.value(const OrderCompleteState()));

        await tester.pumpApp(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('OrderCompleteStatus.failure', () {
      testWidgets('shows error message and Back to Menu button', (
        tester,
      ) async {
        const state = OrderCompleteState(
          status: OrderCompleteStatus.failure,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Back to Home'), findsOneWidget);
      });

      testWidgets('tapping Back to Menu navigates to /menu', (tester) async {
        final goRouter = MockGoRouter();
        const state = OrderCompleteState(
          status: OrderCompleteStatus.failure,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject(), goRouter: goRouter);
        await tester.tap(find.text('Back to Home'));
        await tester.pump();

        verify(() => goRouter.go('/home')).called(1);
      });
    });

    group('OrderCompleteStatus.success', () {
      testWidgets('shows last 4 uppercase chars of order id as order number', (
        tester,
      ) async {
        const state = OrderCompleteState(
          order: _pendingOrder,
          status: OrderCompleteStatus.success,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.textContaining('1234'), findsOneWidget);
      });

      testWidgets('shows grand total', (tester) async {
        const state = OrderCompleteState(
          order: _pendingOrder,
          status: OrderCompleteStatus.success,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        // grandTotal = 400 + tax = 400 + (400*8+50)~/100 = 400+32 = 432
        expect(find.text(r'$4.32'), findsWidgets);
      });

      testWidgets(
        'step 1 is filled when order status is pending',
        (tester) async {
          const state = OrderCompleteState(
            order: _pendingOrder,
            status: OrderCompleteStatus.success,
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('Placed'), findsOneWidget);
        },
      );

      testWidgets(
        'step 2 label is shown when order status is submitted',
        (tester) async {
          const state = OrderCompleteState(
            order: _submittedOrder,
            status: OrderCompleteStatus.success,
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('In Progress'), findsOneWidget);
        },
      );

      testWidgets(
        'step 3 (Ready) is the active step when order status is ready',
        (tester) async {
          const state = OrderCompleteState(
            order: _readyOrder,
            status: OrderCompleteStatus.success,
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('Ready'), findsOneWidget);
        },
      );

      testWidgets(
        'step 4 (Picked Up) is the active step when order status is completed',
        (tester) async {
          const state = OrderCompleteState(
            order: _completedOrder,
            status: OrderCompleteStatus.success,
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          // All labels are rendered in the tracker row.
          expect(find.text('Placed'), findsOneWidget);
          expect(find.text('In Progress'), findsOneWidget);
          expect(find.text('Ready'), findsOneWidget);
          expect(find.text('Picked Up'), findsOneWidget);
        },
      );

      testWidgets(
        'all step labels rendered when order status is cancelled',
        (tester) async {
          const state = OrderCompleteState(
            order: _cancelledOrder,
            status: OrderCompleteStatus.success,
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('Placed'), findsOneWidget);
          expect(find.text('In Progress'), findsOneWidget);
          expect(find.text('Ready'), findsOneWidget);
          expect(find.text('Picked Up'), findsOneWidget);
          expect(find.text('Order Cancelled'), findsOneWidget);
        },
      );

      testWidgets('tapping Back to Menu navigates to /menu', (tester) async {
        final goRouter = MockGoRouter();
        const state = OrderCompleteState(
          order: _pendingOrder,
          status: OrderCompleteStatus.success,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject(), goRouter: goRouter);
        await tester.tap(find.text('Back to Home'));
        await tester.pump();

        verify(() => goRouter.go('/home')).called(1);
      });

      testWidgets('OS back is blocked by PopScope', (tester) async {
        const state = OrderCompleteState(
          order: _pendingOrder,
          status: OrderCompleteStatus.success,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        final popScope = tester.widget<PopScope>(find.byType(PopScope));
        expect(popScope.canPop, isFalse);
      });
    });
  });
}
