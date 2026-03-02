import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/checkout/checkout.dart';

import '../../helpers/helpers.dart';

class _MockCheckoutBloc extends MockBloc<CheckoutEvent, CheckoutState>
    implements CheckoutBloc {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Espresso',
  price: 550,
  options: 'Large',
);

const _testOrder = Order(
  id: 'order-abc-1234',
  items: [_testItem],
  status: OrderStatus.pending,
);

void main() {
  group('CheckoutView', () {
    late CheckoutBloc bloc;

    setUp(() {
      bloc = _MockCheckoutBloc();
    });

    Widget buildSubject() => BlocProvider.value(
      value: bloc,
      child: const CheckoutView(),
    );

    group('CheckoutStatus.loading', () {
      testWidgets('shows CircularProgressIndicator', (tester) async {
        when(() => bloc.state).thenReturn(const CheckoutState());
        whenListen(bloc, Stream.value(const CheckoutState()));

        await tester.pumpApp(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('CheckoutStatus.failure with null order', () {
      testWidgets('shows error message', (tester) async {
        const state = CheckoutState(status: CheckoutStatus.failure);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.text('Something went wrong'), findsOneWidget);
      });
    });

    group('CheckoutStatus.idle', () {
      setUp(() {
        const state = CheckoutState(
          order: _testOrder,
          status: CheckoutStatus.idle,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));
      });

      testWidgets('shows order summary', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.text('Order Summary'), findsOneWidget);
      });

      testWidgets('shows subtotal, tax and total', (tester) async {
        await tester.pumpApp(buildSubject());
        // subtotal = 550 => $5.50, tax = (550*8+50)~/100 = 44 => $0.44
        // grandTotal = 594 => $5.94
        expect(find.text(r'$5.50'), findsWidgets);
        expect(find.text(r'$0.44'), findsOneWidget);
        expect(find.text(r'$5.94'), findsWidgets);
      });

      testWidgets('shows Place Order button with total', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.textContaining('Place Order'), findsOneWidget);
      });

      testWidgets('tapping Place Order dispatches CheckoutConfirmed', (
        tester,
      ) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.textContaining('Place Order'));
        await tester.pump();

        verify(() => bloc.add(const CheckoutConfirmed())).called(1);
      });

      testWidgets('back arrow navigates to /menu/cart', (tester) async {
        final goRouter = MockGoRouter();
        await tester.pumpApp(buildSubject(), goRouter: goRouter);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();

        verify(() => goRouter.go('/menu/cart')).called(1);
      });
    });

    group('CheckoutStatus.submitting', () {
      testWidgets('Place Order button is disabled and shows spinner', (
        tester,
      ) async {
        const state = CheckoutState(
          order: _testOrder,
          status: CheckoutStatus.submitting,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        // Button shows CircularProgressIndicator instead of text
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.textContaining('Place Order'), findsNothing);
      });
    });

    group('CheckoutStatus.failure with non-null order', () {
      testWidgets('shows inline error message below button', (tester) async {
        const state = CheckoutState(
          order: _testOrder,
          status: CheckoutStatus.failure,
        );
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
      });
    });

    group('CheckoutStatus.success', () {
      testWidgets('navigates to confirmation route', (tester) async {
        final goRouter = MockGoRouter();
        const successState = CheckoutState(
          order: _testOrder,
          status: CheckoutStatus.success,
        );
        when(() => bloc.state).thenReturn(
          const CheckoutState(
            order: _testOrder,
            status: CheckoutStatus.idle,
          ),
        );
        whenListen(bloc, Stream.value(successState));

        await tester.pumpApp(buildSubject(), goRouter: goRouter);

        verify(
          () => goRouter.go(
            '/menu/cart/checkout/confirmation/order-abc-1234',
          ),
        ).called(1);
      });
    });
  });
}
