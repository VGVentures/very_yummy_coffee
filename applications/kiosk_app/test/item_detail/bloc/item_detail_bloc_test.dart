import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/item_detail/item_detail.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('ItemDetailBloc', () {
    late MenuRepository menuRepository;
    late OrderRepository orderRepository;
    const groupId = 'group-1';
    const itemId = 'item-1';
    const testGroup = MenuGroup(
      id: groupId,
      name: 'Coffee',
      description: 'Hot beverages',
      color: 0xFFC96B45,
    );
    const item = MenuItem(
      id: itemId,
      name: 'Latte',
      price: 500,
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

    test('initial state is ItemDetailState', () {
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());
      expect(
        ItemDetailBloc(
          menuRepository: menuRepository,
          orderRepository: orderRepository,
        ).state,
        const ItemDetailState(),
      );
    });

    group('ItemDetailSubscriptionRequested', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits idle state with item on success',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer(
            (_) => Stream.value((
              groups: [testGroup],
              items: [item],
              modifierGroups: testModifierGroups,
            )),
          );
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(
          const ItemDetailSubscriptionRequested(groupId, itemId),
        ),
        expect: () => [
          ItemDetailState(
            item: item,
            status: ItemDetailStatus.idle,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits failure on error',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => Stream.error(Exception('error')));
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(
          const ItemDetailSubscriptionRequested(groupId, itemId),
        ),
        expect: () => [
          const ItemDetailState(status: ItemDetailStatus.failure),
        ],
      );
    });

    group('ItemDetailModifierOptionToggled', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits state with updated modifier selection',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => const Stream.empty());
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
          applicableModifierGroups: testModifierGroups,
          selectedModifiers: const {
            'mg-size': ['size-tall'],
          },
        ),
        act: (bloc) => bloc.add(
          const ItemDetailModifierOptionToggled(
            groupId: 'mg-size',
            optionId: 'size-grande',
          ),
        ),
        expect: () => [
          ItemDetailState(
            item: item,
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
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => const Stream.empty());
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => const ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
        ),
        act: (bloc) => bloc.add(const ItemDetailQuantityIncremented()),
        expect: () => [
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.idle,
            quantity: 2,
          ),
        ],
      );
    });

    group('ItemDetailQuantityDecremented', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'decrements quantity (min 1)',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => const Stream.empty());
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => const ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
        ),
        act: (bloc) => bloc.add(const ItemDetailQuantityDecremented()),
        expect: () => <ItemDetailState>[],
      );
    });

    group('ItemDetailAddToCartRequested', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [adding, added] on success',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => const Stream.empty());
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              modifiers: any(named: 'modifiers'),
            ),
          ).thenAnswer((_) async {});
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
          applicableModifierGroups: testModifierGroups,
          selectedModifiers: const {
            'mg-size': ['size-tall'],
          },
        ),
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          ItemDetailState(
            item: item,
            status: ItemDetailStatus.adding,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
          ItemDetailState(
            item: item,
            status: ItemDetailStatus.added,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits failure when item is null',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => const Stream.empty());
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          const ItemDetailState(status: ItemDetailStatus.failure),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [adding, failure] on error',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => const Stream.empty());
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              modifiers: any(named: 'modifiers'),
            ),
          ).thenThrow(Exception('error'));
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
          applicableModifierGroups: testModifierGroups,
          selectedModifiers: const {
            'mg-size': ['size-tall'],
          },
        ),
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          ItemDetailState(
            item: item,
            status: ItemDetailStatus.adding,
            applicableModifierGroups: testModifierGroups,
            selectedModifiers: const {
              'mg-size': ['size-tall'],
            },
          ),
          ItemDetailState(
            item: item,
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
