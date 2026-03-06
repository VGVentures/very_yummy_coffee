import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/widgets/widgets.dart';

import '../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('KioskHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpApp(
        const KioskHeader(title: 'Test Title'),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpApp(
        const KioskHeader(title: 'Title', subtitle: 'Subtitle'),
      );

      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('does not render back button by default', (tester) async {
      await tester.pumpApp(
        const KioskHeader(title: 'Title'),
      );

      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });

    testWidgets('renders back button when showBackButton is true', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpApp(
        KioskHeader(
          title: 'Title',
          showBackButton: true,
          onBack: () => tapped = true,
        ),
      );

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(tapped, isTrue);
    });

    testWidgets('renders cart badge with count when showCartBadge is true', (
      tester,
    ) async {
      final orderRepository = _MockOrderRepository();
      when(() => orderRepository.currentOrderStream).thenAnswer(
        (_) => Stream.value(
          const Order(
            id: 'o1',
            items: [
              LineItem(id: 'a', name: 'Latte', price: 500, quantity: 3),
              LineItem(id: 'b', name: 'Mocha', price: 600, quantity: 2),
            ],
            status: OrderStatus.pending,
          ),
        ),
      );

      await tester.pumpApp(
        const KioskHeader(
          title: 'Title',
          showCartBadge: true,
        ),
        orderRepository: orderRepository,
      );
      await tester.pump();

      expect(find.text('Cart (5)'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });

    testWidgets('does not render cart badge when showCartBadge is false', (
      tester,
    ) async {
      await tester.pumpApp(
        const KioskHeader(title: 'Title'),
      );

      expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing);
    });

    testWidgets('cart badge tap navigates to cart', (tester) async {
      final orderRepository = _MockOrderRepository();
      final goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
      when(() => orderRepository.currentOrderStream).thenAnswer(
        (_) => Stream.value(
          const Order(
            id: 'o1',
            items: [
              LineItem(id: 'a', name: 'Latte', price: 500, quantity: 2),
            ],
            status: OrderStatus.pending,
          ),
        ),
      );

      await tester.pumpApp(
        const KioskHeader(
          title: 'Title',
          showCartBadge: true,
        ),
        orderRepository: orderRepository,
        goRouter: goRouter,
      );
      await tester.pump();

      await tester.tap(find.text('Cart (2)'));
      verify(() => goRouter.go('/home/menu/cart')).called(1);
    });
  });
}
