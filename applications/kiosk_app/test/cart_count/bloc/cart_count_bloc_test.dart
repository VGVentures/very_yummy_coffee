import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/cart_count/cart_count.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('CartCountBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state has itemCount 0', () {
      when(
        () => orderRepository.currentOrderStream,
      ).thenAnswer((_) => const Stream.empty());
      expect(
        CartCountBloc(orderRepository: orderRepository).state,
        const CartCountState(),
      );
    });

    group('CartCountSubscriptionRequested', () {
      blocTest<CartCountBloc, CartCountState>(
        'emits itemCount 0 when order is null',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => Stream.value(null));
          return CartCountBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CartCountSubscriptionRequested()),
        expect: () => [const CartCountState()],
      );

      blocTest<CartCountBloc, CartCountState>(
        'emits sum of item quantities',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(
              const Order(
                id: '1',
                items: [
                  LineItem(id: 'a', name: 'Latte', price: 500, quantity: 2),
                  LineItem(id: 'b', name: 'Muffin', price: 350),
                ],
                status: OrderStatus.pending,
              ),
            ),
          );
          return CartCountBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CartCountSubscriptionRequested()),
        expect: () => [const CartCountState(itemCount: 3)],
      );

      blocTest<CartCountBloc, CartCountState>(
        'emits updated count on order update',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.fromIterable([
              const Order(
                id: '1',
                items: [
                  LineItem(id: 'a', name: 'Latte', price: 500),
                ],
                status: OrderStatus.pending,
              ),
              const Order(
                id: '1',
                items: [
                  LineItem(id: 'a', name: 'Latte', price: 500, quantity: 3),
                ],
                status: OrderStatus.pending,
              ),
            ]),
          );
          return CartCountBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CartCountSubscriptionRequested()),
        expect: () => [
          const CartCountState(itemCount: 1),
          const CartCountState(itemCount: 3),
        ],
      );
    });
  });
}
