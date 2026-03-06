import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/cart/cart.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('CartBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state is CartState', () {
      when(
        () => orderRepository.currentOrderStream,
      ).thenAnswer((_) => const Stream.empty());
      expect(
        CartBloc(orderRepository: orderRepository).state,
        const CartState(),
      );
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
                  LineItem(id: 'a', name: 'Latte', price: 500),
                ],
                status: OrderStatus.pending,
              ),
            ),
          );
          return CartBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [
          const CartState(
            status: CartStatus.success,
            order: Order(
              id: '1',
              items: [LineItem(id: 'a', name: 'Latte', price: 500)],
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
          return CartBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CartSubscriptionRequested()),
        expect: () => [const CartState(status: CartStatus.failure)],
      );
    });

    group('CartItemQuantityUpdated', () {
      blocTest<CartBloc, CartState>(
        'calls updateItemQuantity on repository',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => const Stream.empty());
          when(
            () => orderRepository.updateItemQuantity(any(), any()),
          ).thenReturn(null);
          return CartBloc(orderRepository: orderRepository);
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
