import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';

import '../../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('CartPage', () {
    testWidgets('renders CartView', (tester) async {
      final orderRepository = _MockOrderRepository();
      final menuRepository = _MockMenuRepository();
      when(
        () => orderRepository.currentOrderStream,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpApp(
        const CartPage(),
        orderRepository: orderRepository,
        menuRepository: menuRepository,
      );

      expect(find.byType(CartView), findsOneWidget);
    });
  });
}
