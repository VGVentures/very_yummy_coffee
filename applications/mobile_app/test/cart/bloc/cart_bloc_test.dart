import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Espresso',
  price: 300,
  options: 'Medium · Whole Milk',
  quantity: 2,
);

const _testOrder = Order(
  id: 'order-1',
  items: [_testItem],
  status: OrderStatus.pending,
);

void main() {
  group('CartBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    CartBloc buildBloc() => CartBloc(orderRepository: orderRepository);

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
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(order: _testOrder, status: CartStatus.success),
        ],
      );

      blocTest<CartBloc, CartState>(
        'emits [failure] on stream error',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.error(Exception('oops')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(status: CartStatus.failure),
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
