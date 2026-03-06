import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/order_complete/order_complete.dart';

import '../../helpers/helpers.dart';

class _MockOrderCompleteBloc
    extends MockBloc<OrderCompleteEvent, OrderCompleteState>
    implements OrderCompleteBloc {}

void main() {
  group('OrderCompleteView', () {
    late OrderCompleteBloc orderCompleteBloc;
    late GoRouter goRouter;
    const order = Order(
      id: 'order-1',
      items: [LineItem(id: 'a', name: 'Latte', price: 500)],
      status: OrderStatus.submitted,
    );

    setUp(() {
      orderCompleteBloc = _MockOrderCompleteBloc();
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: orderCompleteBloc,
        child: const OrderCompleteView(),
      );
    }

    void setKioskViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('renders loading indicator when loading', (tester) async {
      when(
        () => orderCompleteBloc.state,
      ).thenReturn(const OrderCompleteState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders success hero on success', (tester) async {
      setKioskViewport(tester);
      when(() => orderCompleteBloc.state).thenReturn(
        const OrderCompleteState(
          status: OrderCompleteStatus.success,
          order: order,
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Order Placed!'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('renders order tracker on success', (tester) async {
      setKioskViewport(tester);
      when(() => orderCompleteBloc.state).thenReturn(
        const OrderCompleteState(
          status: OrderCompleteStatus.success,
          order: order,
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Placed'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Picked Up'), findsOneWidget);
    });

    testWidgets('dispatches done event on button tap', (tester) async {
      setKioskViewport(tester);
      when(() => orderCompleteBloc.state).thenReturn(
        const OrderCompleteState(
          status: OrderCompleteStatus.success,
          order: order,
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);
      await tester.tap(find.text('Done'));

      verify(
        () => orderCompleteBloc.add(const OrderCompleteDoneRequested()),
      ).called(1);
    });

    testWidgets('navigates to /home on navigatingBack status', (
      tester,
    ) async {
      setKioskViewport(tester);
      when(() => orderCompleteBloc.state).thenReturn(
        const OrderCompleteState(
          status: OrderCompleteStatus.success,
          order: order,
        ),
      );
      whenListen(
        orderCompleteBloc,
        Stream.value(
          const OrderCompleteState(
            status: OrderCompleteStatus.navigatingBack,
            order: order,
          ),
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);
      await tester.pumpAndSettle();

      verify(() => goRouter.go('/home')).called(1);
    });

    testWidgets('renders error state with back button', (tester) async {
      when(() => orderCompleteBloc.state).thenReturn(
        const OrderCompleteState(status: OrderCompleteStatus.failure),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
