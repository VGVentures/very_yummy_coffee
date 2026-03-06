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
    const item = MenuItem(
      id: itemId,
      name: 'Latte',
      price: 500,
      groupId: groupId,
    );

    setUp(() {
      menuRepository = _MockMenuRepository();
      orderRepository = _MockOrderRepository();
    });

    test('initial state is ItemDetailState', () {
      when(
        () => menuRepository.getMenuItem(any(), any()),
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
            () => menuRepository.getMenuItem(groupId, itemId),
          ).thenAnswer((_) => Stream.value(item));
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        act: (bloc) => bloc.add(
          const ItemDetailSubscriptionRequested(groupId, itemId),
        ),
        expect: () => [
          const ItemDetailState(item: item, status: ItemDetailStatus.idle),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits failure on error',
        build: () {
          when(
            () => menuRepository.getMenuItem(groupId, itemId),
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

    group('ItemDetailSizeSelected', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits state with selected size',
        build: () {
          when(
            () => menuRepository.getMenuItem(any(), any()),
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
        act: (bloc) => bloc.add(const ItemDetailSizeSelected(DrinkSize.large)),
        expect: () => [
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.idle,
            selectedSize: DrinkSize.large,
          ),
        ],
      );
    });

    group('ItemDetailMilkSelected', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits state with selected milk',
        build: () {
          when(
            () => menuRepository.getMenuItem(any(), any()),
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
        act: (bloc) => bloc.add(const ItemDetailMilkSelected(MilkOption.oat)),
        expect: () => [
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.idle,
            selectedMilk: MilkOption.oat,
          ),
        ],
      );
    });

    group('ItemDetailExtraToggled', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'adds extra when not already selected',
        build: () {
          when(
            () => menuRepository.getMenuItem(any(), any()),
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
        act: (bloc) =>
            bloc.add(const ItemDetailExtraToggled(DrinkExtra.extraShot)),
        expect: () => [
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.idle,
            selectedExtras: [DrinkExtra.extraShot],
          ),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'removes extra when already selected',
        build: () {
          when(
            () => menuRepository.getMenuItem(any(), any()),
          ).thenAnswer((_) => const Stream.empty());
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => const ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
          selectedExtras: [DrinkExtra.extraShot],
        ),
        act: (bloc) =>
            bloc.add(const ItemDetailExtraToggled(DrinkExtra.extraShot)),
        expect: () => [
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.idle,
          ),
        ],
      );
    });

    group('ItemDetailQuantityIncremented', () {
      blocTest<ItemDetailBloc, ItemDetailState>(
        'increments quantity',
        build: () {
          when(
            () => menuRepository.getMenuItem(any(), any()),
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
            () => menuRepository.getMenuItem(any(), any()),
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
            () => menuRepository.getMenuItem(any(), any()),
          ).thenAnswer((_) => const Stream.empty());
          when(() => orderRepository.currentOrderId).thenReturn(null);
          when(() => orderRepository.createOrder()).thenAnswer((_) async {});
          when(
            () => orderRepository.addItemToCurrentOrder(
              itemName: any(named: 'itemName'),
              itemPrice: any(named: 'itemPrice'),
              quantity: any(named: 'quantity'),
              options: any(named: 'options'),
            ),
          ).thenReturn(null);
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => const ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
        ),
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.adding,
          ),
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.added,
          ),
        ],
      );

      blocTest<ItemDetailBloc, ItemDetailState>(
        'emits failure when item is null',
        build: () {
          when(
            () => menuRepository.getMenuItem(any(), any()),
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
            () => menuRepository.getMenuItem(any(), any()),
          ).thenAnswer((_) => const Stream.empty());
          when(() => orderRepository.currentOrderId).thenReturn(null);
          when(
            () => orderRepository.createOrder(),
          ).thenThrow(Exception('error'));
          return ItemDetailBloc(
            menuRepository: menuRepository,
            orderRepository: orderRepository,
          );
        },
        seed: () => const ItemDetailState(
          item: item,
          status: ItemDetailStatus.idle,
        ),
        act: (bloc) => bloc.add(const ItemDetailAddToCartRequested()),
        expect: () => [
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.adding,
          ),
          const ItemDetailState(
            item: item,
            status: ItemDetailStatus.failure,
          ),
        ],
      );
    });
  });
}
