import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_mobile_app/menu_items/menu_items.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('MenuItemsBloc', () {
    late MenuRepository menuRepository;
    const groupId = 'drinks';

    const testGroup = MenuGroup(
      id: groupId,
      name: 'Drinks',
      description: 'Coffee, tea & beverages',
      color: 0xFFC96B45,
    );

    const testItems = [
      MenuItem(id: '1', name: 'Espresso', price: 300, groupId: groupId),
      MenuItem(id: '2', name: 'Latte', price: 475, groupId: groupId),
    ];

    setUp(() {
      menuRepository = _MockMenuRepository();
    });

    test('initial state is MenuItemsState with status initial', () {
      when(
        () => menuRepository.getMenuGroups(),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => menuRepository.getMenuItems(any()),
      ).thenAnswer((_) => const Stream.empty());
      expect(
        MenuItemsBloc(
          menuRepository: menuRepository,
          groupId: groupId,
        ).state,
        const MenuItemsState(),
      );
    });

    group('MenuItemsSubscriptionRequested', () {
      blocTest<MenuItemsBloc, MenuItemsState>(
        'emits [loading, success] with group and items when both streams emit',
        build: () {
          when(
            menuRepository.getMenuGroups,
          ).thenAnswer((_) => Stream.value([testGroup]));
          when(
            () => menuRepository.getMenuItems(groupId),
          ).thenAnswer((_) => Stream.value(testItems));
          return MenuItemsBloc(
            menuRepository: menuRepository,
            groupId: groupId,
          );
        },
        act: (bloc) => bloc.add(const MenuItemsSubscriptionRequested()),
        expect: () => [
          const MenuItemsState(status: MenuItemsStatus.loading),
          const MenuItemsState(
            status: MenuItemsStatus.success,
            group: testGroup,
            menuItems: testItems,
          ),
        ],
      );

      blocTest<MenuItemsBloc, MenuItemsState>(
        'emits [loading, failure] when stream throws',
        build: () {
          when(
            menuRepository.getMenuGroups,
          ).thenAnswer((_) => Stream.error(Exception('fetch error')));
          when(
            () => menuRepository.getMenuItems(groupId),
          ).thenAnswer((_) => Stream.error(Exception('fetch error')));
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
