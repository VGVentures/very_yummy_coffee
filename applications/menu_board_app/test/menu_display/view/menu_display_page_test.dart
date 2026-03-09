import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/menu_display_page.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/menu_display_view.dart';

import '../../helpers/helpers.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('MenuDisplayPage', () {
    late MenuRepository menuRepository;
    late OrderRepository orderRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
      orderRepository = _MockOrderRepository();
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => orderRepository.ordersStream,
      ).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('provides MenuDisplayBloc and dispatches subscription event', (
      tester,
    ) async {
      await tester.pumpApp(
        const MenuDisplayPage(),
        menuRepository: menuRepository,
        orderRepository: orderRepository,
      );

      verify(() => menuRepository.getMenuGroupsAndItems()).called(1);
    });

    testWidgets('provides OrderStatusBloc and renders MenuDisplayView', (
      tester,
    ) async {
      await tester.pumpApp(
        const MenuDisplayPage(),
        menuRepository: menuRepository,
        orderRepository: orderRepository,
      );

      // MenuDisplayView is rendered, which requires both blocs to be provided.
      expect(find.byType(MenuDisplayView), findsOneWidget);
    });
  });
}
