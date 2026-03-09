import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';

class _FakeSelectedModifier extends Fake implements SelectedModifier {}

class _MockMenuRepository extends Mock implements MenuRepository {}

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  const tGroup = MenuGroup(
    id: 'g1',
    name: 'Espresso',
    description: 'Espresso drinks',
    color: 0xFF795548,
  );
  const tItem = MenuItem(
    id: 'i1',
    groupId: 'g1',
    name: 'Latte',
    price: 550,
  );
  const tUnavailableItem = MenuItem(
    id: 'i2',
    groupId: 'g1',
    name: 'Mocha',
    price: 600,
    available: false,
  );

  setUpAll(() {
    registerFallbackValue(_FakeSelectedModifier());
  });

  group('MenuBloc', () {
    late MenuRepository menuRepository;
    late OrderRepository orderRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
      orderRepository = _MockOrderRepository();
    });

    test('initial state is MenuState with loading status', () {
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());
      expect(
        MenuBloc(
          menuRepository: menuRepository,
          orderRepository: orderRepository,
        ).state,
        const MenuState(),
      );
    });

    group('MenuSubscriptionRequested', () {
      blocTest<MenuBloc, MenuState>(
        'emits [loading, success] when data arrives',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(
              (
                groups: [tGroup],
                items: [tItem],
                modifierGroups: const <ModifierGroup>[],
              ),
            ),
          );
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(const MenuSubscriptionRequested()),
        expect: () => [
          const MenuState(),
          const MenuState(
            status: MenuStatus.success,
            groups: [tGroup],
            allItems: [tItem],
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'emits [loading, failure] when stream errors',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.error(Exception('network error')),
          );
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(const MenuSubscriptionRequested()),
        expect: () => [
          const MenuState(),
          const MenuState(status: MenuStatus.failure),
        ],
      );
    });

    group('MenuCategorySelected', () {
      blocTest<MenuBloc, MenuState>(
        'emits state with selected groupId',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(const MenuCategorySelected('g1')),
        expect: () => [
          const MenuState(selectedGroupId: 'g1'),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'emits state with null groupId when All selected',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => const MenuState(selectedGroupId: 'g1'),
        act: (bloc) => bloc.add(const MenuCategorySelected(null)),
        expect: () => [
          const MenuState(),
        ],
      );
    });

    group('MenuItemAdded', () {
      blocTest<MenuBloc, MenuState>(
        'calls addItemToCurrentOrder for available item',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              menuItemId: any(named: 'menuItemId'),
            ),
          ).thenAnswer((_) async {});
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(const MenuItemAdded(tItem)),
        expect: () => <MenuState>[],
        verify: (_) {
          verify(
            () => orderRepository.addItemToCurrentOrder(
              itemName: tItem.name,
              itemPrice: tItem.price,
              quantity: 1,
              menuItemId: tItem.id,
            ),
          ).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'emits [failure] when addItemToCurrentOrder throws',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              menuItemId: any(named: 'menuItemId'),
            ),
          ).thenThrow(Exception('network error'));
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(const MenuItemAdded(tItem)),
        expect: () => [
          const MenuState(status: MenuStatus.failure),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'does not call addItemToCurrentOrder for unavailable item',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(const MenuItemAdded(tUnavailableItem)),
        expect: () => <MenuState>[],
        verify: (_) {
          verifyNever(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              menuItemId: any(named: 'menuItemId'),
            ),
          );
        },
      );
    });

    group('MenuItemAdded with modifiers', () {
      const tModifiers = [
        SelectedModifier(
          modifierGroupId: 'mg-size',
          modifierGroupName: 'Size',
          options: [SelectedOption(id: 'size-m', name: 'Medium')],
        ),
      ];

      blocTest<MenuBloc, MenuState>(
        'calls addItemToCurrentOrder with modifiers for available item',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              menuItemId: any(named: 'menuItemId'),
              modifiers: any(named: 'modifiers'),
            ),
          ).thenAnswer((_) async {});
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(
          const MenuItemAdded(tItem, modifiers: tModifiers),
        ),
        expect: () => <MenuState>[],
        verify: (_) {
          verify(
            () => orderRepository.addItemToCurrentOrder(
              itemName: tItem.name,
              itemPrice: tItem.price,
              quantity: 1,
              menuItemId: tItem.id,
              modifiers: tModifiers,
            ),
          ).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'does not call addItemToCurrentOrder for unavailable item',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(
          const MenuItemAdded(
            tUnavailableItem,
            modifiers: tModifiers,
          ),
        ),
        expect: () => <MenuState>[],
        verify: (_) {
          verifyNever(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              menuItemId: any(named: 'menuItemId'),
              modifiers: any(named: 'modifiers'),
            ),
          );
        },
      );

      blocTest<MenuBloc, MenuState>(
        'emits [failure] when addItemToCurrentOrder throws',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              menuItemId: any(named: 'menuItemId'),
              modifiers: any(named: 'modifiers'),
            ),
          ).thenThrow(Exception('network error'));
          return MenuBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(
          const MenuItemAdded(tItem, modifiers: tModifiers),
        ),
        expect: () => [
          const MenuState(status: MenuStatus.failure),
        ],
      );
    });
  });
}
