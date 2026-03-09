import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/item_detail/item_detail.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('ItemDetailBloc', () {
    late MenuRepository menuRepository;
    late OrderRepository orderRepository;

    const groupId = '2';
    const itemId = '201';
    const testGroup = MenuGroup(
      id: groupId,
      name: 'Drinks',
      description: 'desc',
      color: 0xFF000000,
    );
    const testItem = MenuItem(
      id: itemId,
      name: 'Flat White',
      price: 550,
      groupId: groupId,
    );
    final testModifierGroups = [
      const ModifierGroup(
        id: 'mg-size',
        name: 'Size',
        appliesToGroupIds: [groupId],
        required: true,
        defaultOptionId: 'size-tall',
        options: [
          ModifierOption(id: 'size-tall', name: 'Tall'),
          ModifierOption(
            id: 'size-grande',
            name: 'Grande',
            priceDeltaCents: 50,
          ),
        ],
      ),
    ];

    setUp(() {
      menuRepository = _MockMenuRepository();
      orderRepository = _MockOrderRepository();
    });

    ItemDetailBloc buildBloc() => ItemDetailBloc(
      menuRepository: menuRepository,
      orderRepository: orderRepository,
    );

    test('initial state is ItemDetailState with status loading', () {
      expect(buildBloc().state, const ItemDetailState());
    });

    group('ItemDetailSubscriptionRequested', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [idle with item and modifiers] when item is found',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer(
            (_) => Stream.value((
              groups: [testGroup],
              items: [testItem],
              modifierGroups: testModifierGroups,
            )),
          );
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const ItemDetailSubscriptionRequested(groupId, itemId)),
        expect: () => [
          ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.idle,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [failure] when item is not found',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer(
            (_) => Stream.value((
              groups: [testGroup],
              items: const <MenuItem>[],
              modifierGroups: testModifierGroups,
            )),
          );
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const ItemDetailSubscriptionRequested(groupId, itemId)),
        expect: () => [
          const ItemDetailState(status: ItemDetailStatus.failure),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [failure] when stream errors',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => Stream.error(Exception('oops')));
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const ItemDetailSubscriptionRequested(groupId, itemId)),
        expect: () => [
          const ItemDetailState(status: ItemDetailStatus.failure),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'updates item when stream emits multiple values',
        build: () {
          const updatedItem = MenuItem(
            id: itemId,
            name: 'Flat White',
            price: 600,
            groupId: groupId,
          );
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer(
            (_) => Stream.fromIterable([
              (
                groups: [testGroup],
                items: [testItem],
                modifierGroups: testModifierGroups,
              ),
              (
                groups: [testGroup],
                items: [updatedItem],
                modifierGroups: testModifierGroups,
              ),
            ]),
          );
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const ItemDetailSubscriptionRequested(groupId, itemId)),
        expect: () => [
          ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.idle,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
          ItemDetailState(
            item: const MenuItem(
              id: itemId,
              name: 'Flat White',
              price: 600,
              groupId: groupId,
            ),
            status: ItemDetailStatus.idle,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
        ],
      );
    });

    group('ItemDetailModifierOptionToggled', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'updates selectedModifiers for single-select group',
        seed: () => ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
          applicableModifierGroups: testModifierGroups,
          selectedModifiers: const {
            'mg-size': ['size-tall'],
          },
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ItemDetailModifierOptionToggled(
            groupId: 'mg-size',
            optionId: 'size-grande',
          ),
        ),
        expect: () => [
          ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.idle,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-grande'],
            },
          ),
        ],
      );
    });

    group('ItemDetailQuantityIncremented', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'increments quantity',
        build: buildBloc,
        act: (bloc) => bloc.add(const ItemDetailQuantityIncremented()),
        expect: () => [
          const ItemDetailState(quantity: 2),
        ],
      );
    });

    group('ItemDetailQuantityDecremented', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'decrements quantity',
        seed: () => const ItemDetailState(quantity: 3),
        build: buildBloc,
        act: (bloc) => bloc.add(const ItemDetailQuantityDecremented()),
        expect: () => [
          const ItemDetailState(quantity: 2),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'does nothing when quantity is 1',
        build: buildBloc,
        act: (bloc) => bloc.add(const ItemDetailQuantityDecremented()),
        expect: () => <ItemDetailState>[],
      );
    });

    group('ItemDetailAddToCartRequested', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'adds item and emits added',
        seed: () => ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
          applicableModifierGroups: testModifierGroups,
          selectedModifiers: const {
            'mg-size': ['size-tall'],
          },
        ),
        build: () {
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              modifiers: any(named: 'modifiers'),
              menuItemId: any(named: 'menuItemId'),
            ),
          ).thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.adding,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
          ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.added,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
        ],
        verify: (_) {
          verify(
            () => orderRepository.addItemToCurrentOrder(
              itemName: testItem.name,
              itemPrice: testItem.price,
              quantity: 1,
              modifiers: any(named: 'modifiers'),
              menuItemId: any(named: 'menuItemId'),
            ),
          ).called(1);
        },
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'calls addItemToCurrentOrder once with quantity: 3',
        seed: () => ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
          quantity: 3,
          applicableModifierGroups: testModifierGroups,
          selectedModifiers: const {
            'mg-size': ['size-tall'],
          },
        ),
        build: () {
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              modifiers: any(named: 'modifiers'),
              menuItemId: any(named: 'menuItemId'),
            ),
          ).thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        verify: (_) {
          verify(
            () => orderRepository.addItemToCurrentOrder(
              itemName: testItem.name,
              itemPrice: testItem.price,
              quantity: 3,
              modifiers: any(named: 'modifiers'),
              menuItemId: any(named: 'menuItemId'),
            ),
          ).called(1);
        },
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [failure] when item is unavailable',
        seed: () => const ItemDetailState(
          item: MenuItem(
            id: itemId,
            name: 'Flat White',
            price: 550,
            groupId: groupId,
            available: false,
          ),
          status: ItemDetailStatus.idle,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          const ItemDetailState(
            item: MenuItem(
              id: itemId,
              name: 'Flat White',
              price: 550,
              groupId: groupId,
              available: false,
            ),
            status: ItemDetailStatus.failure,
          ),
        ],
        verify: (_) {
          verifyNever(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              modifiers: any(named: 'modifiers'),
              menuItemId: any(named: 'menuItemId'),
            ),
          );
        },
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [adding, failure] on exception',
        seed: () => ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
          applicableModifierGroups: testModifierGroups,
          selectedModifiers: const {
            'mg-size': ['size-tall'],
          },
        ),
        build: () {
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              modifiers: any(named: 'modifiers'),
              menuItemId: any(named: 'menuItemId'),
            ),
          ).thenThrow(Exception('network error'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.adding,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
          ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.failure,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
        ],
      );
    });
  });
}
