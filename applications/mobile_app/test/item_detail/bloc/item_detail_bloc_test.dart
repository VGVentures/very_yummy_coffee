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

    const groupId = 'drinks';
    const itemId = '1';
    const testItem = MenuItem(
      id: itemId,
      name: 'Espresso',
      price: 300,
      groupId: groupId,
    );

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
        'emits [idle with item] when item is found',
        build: () {
          when(
            () => menuRepository.getMenuItem(groupId, itemId),
          ).thenAnswer((_) => Stream.value(testItem));
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const ItemDetailSubscriptionRequested(groupId, itemId)),
        expect: () => [
          const ItemDetailState(item: testItem, status: ItemDetailStatus.idle),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [failure] when item is not found',
        build: () {
          when(
            () => menuRepository.getMenuItem(groupId, itemId),
          ).thenAnswer((_) => Stream.value(null));
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
            () => menuRepository.getMenuItem(groupId, itemId),
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
            name: 'Espresso',
            price: 350,
            groupId: groupId,
          );
          when(
            () => menuRepository.getMenuItem(groupId, itemId),
          ).thenAnswer(
            (_) => Stream.fromIterable([testItem, updatedItem]),
          );
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const ItemDetailSubscriptionRequested(groupId, itemId)),
        expect: () => [
          const ItemDetailState(item: testItem, status: ItemDetailStatus.idle),
          const ItemDetailState(
            item: MenuItem(
              id: itemId,
              name: 'Espresso',
              price: 350,
              groupId: groupId,
            ),
            status: ItemDetailStatus.idle,
          ),
        ],
      );
    });

    group('ItemDetailSizeSelected', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'updates selectedSize',
        build: buildBloc,
        act: (bloc) => bloc.add(const ItemDetailSizeSelected(DrinkSize.large)),
        expect: () => [
          const ItemDetailState(selectedSize: DrinkSize.large),
        ],
      );
    });

    group('ItemDetailMilkSelected', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'updates selectedMilk',
        build: buildBloc,
        act: (bloc) => bloc.add(const ItemDetailMilkSelected(MilkOption.oat)),
        expect: () => [
          const ItemDetailState(selectedMilk: MilkOption.oat),
        ],
      );
    });

    group('ItemDetailExtraToggled', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'adds extra when not selected',
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ItemDetailExtraToggled(DrinkExtra.extraShot)),
        expect: () => [
          const ItemDetailState(
            selectedExtras: [DrinkExtra.extraShot],
          ),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'removes extra when already selected',
        seed: () => const ItemDetailState(
          selectedExtras: [DrinkExtra.extraShot],
        ),
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ItemDetailExtraToggled(DrinkExtra.extraShot)),
        expect: () => [
          const ItemDetailState(),
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
        'creates order then adds item and emits added',
        seed: () => const ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
        ),
        build: () {
          when(() => orderRepository.currentOrderId).thenReturn(null);
          when(
            () => orderRepository.createOrder(),
          ).thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          const ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.adding,
          ),
          const ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.added,
          ),
        ],
        verify: (_) {
          verify(() => orderRepository.createOrder()).called(1);
          verify(
            () => orderRepository.addItemToCurrentOrder(
              itemName: testItem.name,
              itemPrice: testItem.price,
              options: 'Medium · Whole Milk',
              quantity: 1,
            ),
          ).called(1);
        },
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'skips createOrder when order already exists',
        seed: () => const ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
        ),
        build: () {
          when(
            () => orderRepository.currentOrderId,
          ).thenReturn('existing-order');
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          const ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.adding,
          ),
          const ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.added,
          ),
        ],
        verify: (_) {
          verifyNever(() => orderRepository.createOrder());
        },
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'calls addItemToCurrentOrder once with quantity: 3',
        seed: () => const ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
          quantity: 3,
        ),
        build: () {
          when(
            () => orderRepository.currentOrderId,
          ).thenReturn('existing-order');
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        verify: (_) {
          verify(
            () => orderRepository.addItemToCurrentOrder(
              itemName: testItem.name,
              itemPrice: testItem.price,
              options: 'Medium · Whole Milk',
              quantity: 3,
            ),
          ).called(1);
        },
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'includes extras in options string',
        seed: () => const ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
          selectedExtras: [DrinkExtra.extraShot, DrinkExtra.caramel],
        ),
        build: () {
          when(
            () => orderRepository.currentOrderId,
          ).thenReturn('existing-order');
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        verify: (_) {
          verify(
            () => orderRepository.addItemToCurrentOrder(
              itemName: testItem.name,
              itemPrice: testItem.price,
              options: 'Medium · Whole Milk · Extra Shot · Caramel',
              quantity: 1,
            ),
          ).called(1);
        },
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits [adding, failure] on exception',
        seed: () => const ItemDetailState(
          item: testItem,
          status: ItemDetailStatus.idle,
        ),
        build: () {
          when(() => orderRepository.currentOrderId).thenReturn(null);
          when(
            () => orderRepository.createOrder(),
          ).thenThrow(Exception('network error'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          const ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.adding,
          ),
          const ItemDetailState(
            item: testItem,
            status: ItemDetailStatus.failure,
          ),
        ],
      );
    });
  });
}
