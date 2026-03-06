import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_items/menu_items.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('MenuItemsBloc', () {
    late MenuRepository menuRepository;
    const groupId = 'group-1';

    const groups = [
      MenuGroup(
        id: groupId,
        name: 'Coffee',
        description: 'Hot beverages',
        color: 0xFFC96B45,
      ),
    ];

    setUp(() {
      menuRepository = _MockMenuRepository();
      when(
        () => menuRepository.getMenuGroups(),
      ).thenAnswer((_) => Stream.value(groups));
    });

    test('initial state is MenuItemsState', () {
      when(
        () => menuRepository.getMenuItems(any()),
      ).thenAnswer((_) => const Stream.empty());
      expect(
        MenuItemsBloc(menuRepository: menuRepository, groupId: groupId).state,
        const MenuItemsState(),
      );
    });

    group('MenuItemsSubscriptionRequested', () {
      final items = [
        const MenuItem(
          id: 'item-1',
          name: 'Latte',
          price: 500,
          groupId: groupId,
        ),
      ];

      blocTest<MenuItemsBloc, MenuItemsState>(
        'emits [loading, success] with group name on successful subscription',
        build: () {
          when(
            () => menuRepository.getMenuItems(groupId),
          ).thenAnswer((_) => Stream.value(items));
          return MenuItemsBloc(
            menuRepository: menuRepository,
            groupId: groupId,
          );
        },
        act: (bloc) => bloc.add(const MenuItemsSubscriptionRequested()),
        expect: () => [
          const MenuItemsState(status: MenuItemsStatus.loading),
          MenuItemsState(
            status: MenuItemsStatus.success,
            menuItems: items,
            groupName: 'Coffee',
          ),
        ],
      );

      blocTest<MenuItemsBloc, MenuItemsState>(
        'emits [loading, failure] on error',
        build: () {
          when(
            () => menuRepository.getMenuItems(groupId),
          ).thenAnswer((_) => Stream.error(Exception('error')));
          return MenuItemsBloc(
            menuRepository: menuRepository,
            groupId: groupId,
          );
        },
        act: (bloc) => bloc.add(const MenuItemsSubscriptionRequested()),
        expect: () => [
          const MenuItemsState(status: MenuItemsStatus.loading),
          const MenuItemsState(status: MenuItemsStatus.failure),
        ],
      );
    });
  });
}
