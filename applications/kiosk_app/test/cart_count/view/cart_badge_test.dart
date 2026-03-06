import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/cart_count/cart_count.dart';

import '../../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('CartBadge', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    testWidgets('provides CartCountBloc and renders CartBadgeView', (
      tester,
    ) async {
      when(() => orderRepository.currentOrderStream).thenAnswer(
        (_) => Stream.value(
          const Order(
            id: 'o1',
            items: [LineItem(id: 'a', name: 'Latte', price: 500)],
            status: OrderStatus.pending,
          ),
        ),
      );

      await tester.pumpApp(
        const CartBadge(),
        orderRepository: orderRepository,
      );
      await tester.pump();

      expect(find.byType(CartBadgeView), findsOneWidget);
      expect(find.text('Cart (1)'), findsOneWidget);
    });

    testWidgets('renders zero count when no current order', (tester) async {
      when(() => orderRepository.currentOrderStream).thenAnswer(
        (_) => Stream.value(null),
      );

      await tester.pumpApp(
        const CartBadge(),
        orderRepository: orderRepository,
      );
      await tester.pump();

      expect(find.text('Cart (0)'), findsOneWidget);
    });
  });
}
