import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/cart/cart.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

import '../../helpers/helpers.dart';

class _MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

void main() {
  group('CartView', () {
    late CartBloc cartBloc;
    late GoRouter goRouter;

    setUp(() {
      cartBloc = _MockCartBloc();
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: cartBloc,
        child: const CartView(),
      );
    }

    testWidgets('renders loading indicator when loading', (tester) async {
      when(() => cartBloc.state).thenReturn(const CartState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message on failure', (tester) async {
      when(
        () => cartBloc.state,
      ).thenReturn(const CartState(status: CartStatus.failure));

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders empty cart view when no items', (tester) async {
      when(() => cartBloc.state).thenReturn(
        const CartState(
          status: CartStatus.success,
          order: Order(id: '1', items: [], status: OrderStatus.pending),
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Browse Menu'), findsOneWidget);
    });

    testWidgets('shows OutOfStockBadge on unavailable item', (
      tester,
    ) async {
      when(() => cartBloc.state).thenReturn(
        const CartState(
          status: CartStatus.success,
          order: Order(
            id: '1',
            items: [
              LineItem(
                id: 'a',
                name: 'Latte',
                price: 500,
                menuItemId: 'menu-1',
              ),
            ],
            status: OrderStatus.pending,
          ),
          unavailableLineItemIds: ['a'],
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(OutOfStockBadge), findsOneWidget);
    });

    testWidgets('shows warning when cart has unavailable items', (
      tester,
    ) async {
      when(() => cartBloc.state).thenReturn(
        const CartState(
          status: CartStatus.success,
          order: Order(
            id: '1',
            items: [
              LineItem(
                id: 'a',
                name: 'Latte',
                price: 500,
                menuItemId: 'menu-1',
              ),
            ],
            status: OrderStatus.pending,
          ),
          unavailableLineItemIds: ['a'],
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(
        find.text('Remove unavailable items to proceed'),
        findsOneWidget,
      );
    });

    testWidgets('renders cart items on success', (tester) async {
      when(() => cartBloc.state).thenReturn(
        const CartState(
          status: CartStatus.success,
          order: Order(
            id: '1',
            items: [
              LineItem(id: 'a', name: 'Latte', price: 500),
              LineItem(id: 'b', name: 'Mocha', price: 600),
            ],
            status: OrderStatus.pending,
          ),
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Mocha'), findsOneWidget);
    });
  });
}
