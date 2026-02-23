import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';

import '../../helpers/helpers.dart';

class _MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Espresso',
  price: 300,
  options: 'Medium · Oat Milk',
  quantity: 2,
);

const _testOrder = Order(
  id: 'order-1',
  items: [_testItem],
  status: OrderStatus.pending,
);

void main() {
  group('CartView', () {
    late CartBloc bloc;

    setUp(() {
      bloc = _MockCartBloc();
    });

    Widget buildSubject() => BlocProvider.value(
      value: bloc,
      child: const CartView(),
    );

    group('CartStatus.loading', () {
      testWidgets('shows CircularProgressIndicator', (tester) async {
        when(() => bloc.state).thenReturn(const CartState());
        whenListen(bloc, Stream.value(const CartState()));

        await tester.pumpApp(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('CartStatus.failure', () {
      testWidgets('shows error message', (tester) async {
        const state = CartState(status: CartStatus.failure);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.text('Something went wrong'), findsOneWidget);
      });
    });

    group('CartStatus.success', () {
      group('with order containing items', () {
        setUp(() {
          const state = CartState(
            order: _testOrder,
            status: CartStatus.success,
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));
        });

        testWidgets('shows item name', (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.text('Espresso'), findsOneWidget);
        });

        testWidgets('shows item options', (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.text('Medium · Oat Milk'), findsOneWidget);
        });

        testWidgets('shows formatted item price', (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.text(r'$3.00'), findsOneWidget);
        });

        testWidgets('shows subtotal, tax, and total in summary', (
          tester,
        ) async {
          await tester.pumpApp(buildSubject());
          // subtotal = 300 * 2 = 600 => $6.00
          // tax = (600 * 8 + 50) ~/ 100 = 48 => $0.48
          // total = 648 => $6.48
          expect(find.text(r'$6.00'), findsWidgets);
          expect(find.text(r'$0.48'), findsOneWidget);
          expect(find.text(r'$6.48'), findsOneWidget);
        });

        testWidgets('tapping + dispatches CartItemQuantityUpdated with '
            'incremented quantity', (tester) async {
          await tester.pumpApp(buildSubject());

          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();

          verify(
            () => bloc.add(
              const CartItemQuantityUpdated(lineItemId: 'li-1', quantity: 3),
            ),
          ).called(1);
        });

        testWidgets(
          'tapping trash dispatches CartItemQuantityUpdated with quantity 0',
          (tester) async {
            await tester.pumpApp(buildSubject());

            await tester.tap(find.byIcon(Icons.delete_outline));
            await tester.pump();

            verify(
              () => bloc.add(
                const CartItemQuantityUpdated(lineItemId: 'li-1', quantity: 0),
              ),
            ).called(1);
          },
        );

        testWidgets(
          'tapping - dispatches CartItemQuantityUpdated with quantity 1',
          (tester) async {
            await tester.pumpApp(buildSubject());

            await tester.tap(find.byIcon(Icons.remove));
            await tester.pump();

            verify(
              () => bloc.add(
                const CartItemQuantityUpdated(lineItemId: 'li-1', quantity: 1),
              ),
            ).called(1);
          },
        );
      });

      group('with null order', () {
        testWidgets('shows empty cart message', (tester) async {
          const state = CartState(status: CartStatus.success);
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('Your cart is empty'), findsOneWidget);
        });

        testWidgets('shows browse menu button', (tester) async {
          const state = CartState(status: CartStatus.success);
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('Browse Menu'), findsOneWidget);
        });

        testWidgets(
          'tapping Browse Menu navigates to /menu',
          (tester) async {
            final goRouter = MockGoRouter();
            const state = CartState(status: CartStatus.success);
            when(() => bloc.state).thenReturn(state);
            whenListen(bloc, Stream.value(state));

            await tester.pumpApp(buildSubject(), goRouter: goRouter);

            await tester.tap(find.text('Browse Menu'));
            await tester.pump();

            verify(() => goRouter.go('/menu')).called(1);
          },
        );
      });

      group('with empty order', () {
        testWidgets('shows empty cart message', (tester) async {
          const emptyOrder = Order(
            id: 'order-1',
            items: [],
            status: OrderStatus.pending,
          );
          const state = CartState(
            order: emptyOrder,
            status: CartStatus.success,
          );
          when(() => bloc.state).thenReturn(state);
          whenListen(bloc, Stream.value(state));

          await tester.pumpApp(buildSubject());

          expect(find.text('Your cart is empty'), findsOneWidget);
        });
      });
    });
  });
}
