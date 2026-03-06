import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_kiosk_app/cart_count/cart_count.dart';

import '../../helpers/helpers.dart';

class _MockCartCountBloc extends MockBloc<CartCountEvent, CartCountState>
    implements CartCountBloc {}

void main() {
  group('CartBadgeView', () {
    late CartCountBloc cartCountBloc;
    late GoRouter goRouter;

    setUp(() {
      cartCountBloc = _MockCartCountBloc();
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: cartCountBloc,
        child: const CartBadgeView(),
      );
    }

    testWidgets('renders cart icon', (tester) async {
      when(() => cartCountBloc.state).thenReturn(const CartCountState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });

    testWidgets('renders item count from bloc state', (tester) async {
      when(
        () => cartCountBloc.state,
      ).thenReturn(const CartCountState(itemCount: 5));

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Cart (5)'), findsOneWidget);
    });

    testWidgets('renders zero count', (tester) async {
      when(() => cartCountBloc.state).thenReturn(const CartCountState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Cart (0)'), findsOneWidget);
    });

    testWidgets('navigates to cart page when tapped', (tester) async {
      when(
        () => cartCountBloc.state,
      ).thenReturn(const CartCountState(itemCount: 3));

      await tester.pumpApp(buildSubject(), goRouter: goRouter);
      await tester.tap(find.text('Cart (3)'));

      verify(() => goRouter.go('/home/menu/cart')).called(1);
    });

    testWidgets('updates when bloc state changes', (tester) async {
      when(() => cartCountBloc.state).thenReturn(const CartCountState());
      whenListen(
        cartCountBloc,
        Stream.value(const CartCountState(itemCount: 7)),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);
      await tester.pumpAndSettle();

      expect(find.text('Cart (7)'), findsOneWidget);
    });
  });
}
