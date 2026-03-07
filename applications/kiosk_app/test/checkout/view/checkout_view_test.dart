import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/checkout/checkout.dart';

import '../../helpers/helpers.dart';

class _MockCheckoutBloc extends MockBloc<CheckoutEvent, CheckoutState>
    implements CheckoutBloc {}

void main() {
  group('CheckoutView', () {
    late CheckoutBloc checkoutBloc;
    late GoRouter goRouter;
    const order = Order(
      id: 'order-1',
      items: [LineItem(id: 'a', name: 'Latte', price: 500)],
      status: OrderStatus.pending,
    );

    setUp(() {
      checkoutBloc = _MockCheckoutBloc();
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: checkoutBloc,
        child: const CheckoutView(),
      );
    }

    testWidgets('renders loading indicator when loading', (tester) async {
      when(() => checkoutBloc.state).thenReturn(const CheckoutState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders fake payment card on idle', (tester) async {
      when(() => checkoutBloc.state).thenReturn(
        const CheckoutState(status: CheckoutStatus.idle, order: order),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Fake Payment'), findsOneWidget);
      expect(find.text('No real charge will be made'), findsOneWidget);
    });

    testWidgets('renders place order button', (tester) async {
      when(() => checkoutBloc.state).thenReturn(
        const CheckoutState(status: CheckoutStatus.idle, order: order),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.textContaining('Place Order'), findsOneWidget);
    });

    testWidgets('shows error message on failure with order', (tester) async {
      when(() => checkoutBloc.state).thenReturn(
        const CheckoutState(status: CheckoutStatus.failure, order: order),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('renders customer name field with placeholder', (
      tester,
    ) async {
      when(() => checkoutBloc.state).thenReturn(
        const CheckoutState(status: CheckoutStatus.idle, order: order),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(
        find.text('Enter your name (optional)'),
        findsOneWidget,
      );
    });

    testWidgets('navigates to confirmation on success', (tester) async {
      when(() => checkoutBloc.state).thenReturn(
        const CheckoutState(status: CheckoutStatus.idle, order: order),
      );
      whenListen(
        checkoutBloc,
        Stream.value(
          const CheckoutState(status: CheckoutStatus.success, order: order),
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);
      await tester.pumpAndSettle();

      verify(
        () => goRouter.go('/home/menu/cart/checkout/confirmation/order-1'),
      ).called(1);
    });
  });
}
