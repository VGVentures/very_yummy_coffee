import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/home/home.dart';

import '../../helpers/helpers.dart';

class _MockHomeBloc extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc {}

class _MockOrderRepository extends Mock implements OrderRepository {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Espresso',
  price: 300,
);

const _submittedOrder = Order(
  id: 'order-test-5678',
  items: [_testItem, _testItem],
  status: OrderStatus.submitted,
);

const _readyOrder = Order(
  id: 'order-test-9012',
  items: [_testItem],
  status: OrderStatus.ready,
);

void main() {
  group('HomeView', () {
    late HomeBloc bloc;

    setUp(() {
      bloc = _MockHomeBloc();
    });

    Widget buildSubject() => BlocProvider.value(
      value: bloc,
      child: const HomeView(),
    );

    group('HomeStatus.loading', () {
      testWidgets('shows CircularProgressIndicator', (tester) async {
        when(() => bloc.state).thenReturn(const HomeState());
        whenListen(bloc, Stream.value(const HomeState()));

        await tester.pumpApp(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('HomeStatus.failure', () {
      testWidgets('shows error message', (tester) async {
        const state = HomeState(status: HomeStatus.failure);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.text('Something went wrong'), findsOneWidget);
      });
    });

    group('HomeStatus.success', () {
      testWidgets('shows empty state when orders list is empty', (
        tester,
      ) async {
        const state = HomeState(status: HomeStatus.success);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.text('No active orders'), findsOneWidget);
        expect(
          find.text('Tap below to start your first order'),
          findsOneWidget,
        );
      });

      testWidgets('shows order cards when orders are present', (tester) async {
        const state = HomeState(
          status: HomeStatus.success,
          orders: [_submittedOrder, _readyOrder],
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        // Last 4 chars of 'order-test-5678' → '5678'
        expect(find.textContaining('5678'), findsOneWidget);
        // Last 4 chars of 'order-test-9012' → '9012'
        expect(find.textContaining('9012'), findsOneWidget);
      });

      testWidgets('shows Ready status pill for a ready order', (tester) async {
        const state = HomeState(
          status: HomeStatus.success,
          orders: [_readyOrder],
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        // 'Ready' appears in both the status pill and the step tracker.
        expect(find.text('Ready'), findsWidgets);
      });

      testWidgets('shows Start New Order button when no orders', (
        tester,
      ) async {
        const state = HomeState(status: HomeStatus.success);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.text('Start New Order'), findsOneWidget);
      });

      testWidgets(
        'shows Start New Order button when only submitted/ready orders',
        (tester) async {
          const state = HomeState(
            status: HomeStatus.success,
            orders: [_submittedOrder, _readyOrder],
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('Start New Order'), findsOneWidget);
        },
      );

      testWidgets(
        'shows Continue Order button when currentOrderId is set',
        (tester) async {
          const state = HomeState(status: HomeStatus.success);
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          final orderRepository = _MockOrderRepository();
          when(
            () => orderRepository.currentOrderId,
          ).thenReturn('order-in-progress');

          await tester.pumpApp(
            buildSubject(),
            orderRepository: orderRepository,
          );

          expect(find.text('Continue Order'), findsOneWidget);
        },
      );

      testWidgets('tapping Start New Order navigates to /menu', (
        tester,
      ) async {
        final goRouter = MockGoRouter();
        const state = HomeState(status: HomeStatus.success);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject(), goRouter: goRouter);
        await tester.tap(find.text('Start New Order'));
        await tester.pump();

        verify(() => goRouter.go('/home/menu')).called(1);
      });
    });
  });
}
