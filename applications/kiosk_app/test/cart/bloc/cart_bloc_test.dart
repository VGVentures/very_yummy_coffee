import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/cart/cart.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockMenuRepository extends Mock implements MenuRepository {}

const _menuGroup = MenuGroup(
  id: 'g1',
  name: 'Coffee',
  description: '',
  color: 0xFF000000,
);

const _allAvailableMenu = (
  groups: [_menuGroup],
  items: [
    MenuItem(id: 'menu-1', name: 'Latte', price: 500, groupId: 'g1'),
  ],
  modifierGroups: <ModifierGroup>[],
);

const _menuWithUnavailable = (
  groups: [_menuGroup],
  items: [
    MenuItem(
      id: 'menu-1',
      name: 'Latte',
      price: 500,
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

    test('initial state is CartState', () {
      expect(buildBloc().state, const CartState());
    });

    group('CartSubscriptionRequested', () {
      blocTest<CartBloc, CartState>(
        'emits success with order data',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(
              const Order(
                id: '1',
                items: [
                  LineItem(
                    id: 'a',
                    name: 'Latte',
                    price: 500,
                    menuItemId: 'menu-1',
                  ),
                ],
                status: OrderStatus.pending,
              ),
            ),
          );
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_allAvailableMenu),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(
            status: CartStatus.success,
            order: Order(
              id: '1',
              items: [
                LineItem(
                  id: 'a',
                  name: 'Latte',
                  price: 500,
                  menuItemId: 'menu-1',
                ),
              ],
              status: OrderStatus.pending,
            ),
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'emits failure on error',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => Stream.error(Exception('error')));
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_allAvailableMenu),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [const CartState(status: CartStatus.failure)],
      );

      blocTest<CartBloc, CartState>(
        'emits unavailableLineItemIds when menu item is unavailable',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(
              const Order(
                id: '1',
                items: [
                  LineItem(
                    id: 'a',
                    name: 'Latte',
                    price: 500,
                    menuItemId: 'menu-1',
                  ),
                ],
                status: OrderStatus.pending,
              ),
            ),
          );
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(_menuWithUnavailable),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(
            status: CartStatus.success,
            order: Order(
              id: '1',
              items: [
                LineItem(
                  id: 'a',
                  name: 'Latte',
                  price: 500,
                  menuItemId: 'menu-1',
                ),
              ],
              status: OrderStatus.pending,
            ),
            unavailableLineItemIds: ['a'],
          ),
        ],
      );
    });

    group('CartItemQuantityUpdated', () {
      blocTest<CartBloc, CartState>(
        'calls updateItemQuantity on repository',
        build: () {
          when(
            () => orderRepository.updateItemQuantity(any(), any()),
          ).thenReturn(null);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const CartItemQuantityUpdated(lineItemId: 'a', quantity: 2),
        ),
        verify: (_) {
          verify(
            () => orderRepository.updateItemQuantity('a', 2),
          ).called(1);
        },
      );
    });
  });
}
