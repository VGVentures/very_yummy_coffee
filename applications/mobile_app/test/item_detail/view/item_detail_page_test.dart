import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/item_detail/item_detail.dart';

import '../../helpers/helpers.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('ItemDetailPage', () {
    const groupId = 'drinks';
    const itemId = '1';

    late MenuRepository menuRepository;
    late OrderRepository orderRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
      orderRepository = _MockOrderRepository();

      when(
        () => menuRepository.getMenuItem(any(), any()),
      ).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('renders ItemDetailView', (tester) async {
      await tester.pumpApp(
        const ItemDetailPage(
          key: Key('item_detail_page'),
          groupId: groupId,
          itemId: itemId,
        ),
        menuRepository: menuRepository,
        orderRepository: orderRepository,
      );

      expect(find.byType(ItemDetailView), findsOneWidget);
    });

    testWidgets('subscribes to correct item on mount', (tester) async {
      await tester.pumpApp(
        const ItemDetailPage(
          key: Key('item_detail_page'),
          groupId: groupId,
          itemId: itemId,
        ),
        menuRepository: menuRepository,
        orderRepository: orderRepository,
      );

      verify(
        () => menuRepository.getMenuItem(groupId, itemId),
      ).called(1);
    });
  });
}
