import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockMenuRepository extends Mock implements MenuRepository {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Espresso',
  price: 300,
  quantity: 2,
  menuItemId: 'menu-1',
);

const _testOrder = Order(
  id: 'order-1',
  items: [_testItem],
  status: OrderStatus.pending,
);

const _menuGroup = MenuGroup(
  id: 'g1',
  name: 'Coffee',
  description: '',
  color: 0xFF000000,
);

const _allAvailableMenu = (
  groups: [_menuGroup],
  items: [
    MenuItem(id: 'menu-1', name: 'Espresso', price: 300, groupId: 'g1'),
  ],
  modifierGroups: <ModifierGroup>[],
);

const _menuWithUnavailable = (
  groups: [_menuGroup],
  items: [
    MenuItem(
      id: 'menu-1',
      name: 'Espresso',
      price: 300,
      groupId: 'g1',
      available: false,
    ),
  ],
  modifierGroups: <ModifierGroup>[],
);

void main() {
  group('CartBloc', () {
    late OrderRepository orderRepository;
    late MenuRepository menuRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
      menuRepository = _MockMenuRepository();
    });

    CartBloc buildBloc() => CartBloc(
      orderRepository: orderRepository,
      menuRepository: menuRepository,
    );

    test('initial state is CartState(status: CartStatus.loading)', () {
      expect(buildBloc().state, const CartState());
    });

    group('CartSubscriptionRequested', () {
      blocTest<CartBloc, CartState>(
        'emits [success with order] on stream data',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(_testOrder),
          );
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_allAvailableMenu),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(order: _testOrder, status: CartStatus.success),
        ],
      );

      blocTest<CartBloc, CartState>(
        'emits updated order when stream emits multiple values',
        build: () {
          const updatedOrder = Order(
            id: 'order-1',
            items: [_testItem],
            status: OrderStatus.completed,
          );
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.fromIterable([_testOrder, updatedOrder]),
          );
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_allAvailableMenu),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(order: _testOrder, status: CartStatus.success),
          const CartState(
            order: Order(
              id: 'order-1',
              items: [_testItem],
              status: OrderStatus.completed,
            ),
            status: CartStatus.success,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'emits [failure] on stream error',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.error(Exception('oops')),
          );
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_allAvailableMenu),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(status: CartStatus.failure),
        ],
      );

      blocTest<CartBloc, CartState>(
        'emits unavailableLineItemIds when menu item is unavailable',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(_testOrder),
          );
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_menuWithUnavailable),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(
            order: _testOrder,
            status: CartStatus.success,
            unavailableLineItemIds: ['li-1'],
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'emits empty unavailableLineItemIds when all items available',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(_testOrder),
          );
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_allAvailableMenu),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(
            order: _testOrder,
            status: CartStatus.success,
          ),
        ],
      );
    });

    group('CartItemQuantityUpdated', () {
      blocTest<CartBloc, CartState>(
        'calls updateItemQuantity with correct args and emits no state',
        build: () {
          when(
            () => orderRepository.updateItemQuantity(any(), any()),
          ).thenReturn(null);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const CartItemQuantityUpdated(lineItemId: 'li-1', quantity: 3),
        ),
        expect: () => <CartState>[],
        verify: (_) {
          verify(
            () => orderRepository.updateItemQuantity('li-1', 3),
          ).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'calls updateItemQuantity with quantity 0 to remove item',
        build: () {
          when(
            () => orderRepository.updateItemQuantity(any(), any()),
          ).thenReturn(null);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const CartItemQuantityUpdated(lineItemId: 'li-1', quantity: 0),
        ),
        expect: () => <CartState>[],
        verify: (_) {
          verify(
            () => orderRepository.updateItemQuantity('li-1', 0),
          ).called(1);
        },
      );
    });
  });
}
