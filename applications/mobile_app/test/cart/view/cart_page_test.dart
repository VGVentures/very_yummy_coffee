import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';

import '../../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('CartPage', () {
    testWidgets('renders CartView', (tester) async {
      final orderRepository = _MockOrderRepository();
      when(
        () => orderRepository.currentOrderStream,
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpApp(
        const CartPage(),
        orderRepository: orderRepository,
      );

      expect(find.byType(CartView), findsOneWidget);
    });
  });
}
