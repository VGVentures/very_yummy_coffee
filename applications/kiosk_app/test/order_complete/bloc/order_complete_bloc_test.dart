import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/order_complete/order_complete.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderCompleteBloc', () {
    late OrderRepository orderRepository;
    const orderId = 'order-1';
    const order = Order(
      id: orderId,
      items: [LineItem(id: 'a', name: 'Latte', price: 500)],
      status: OrderStatus.submitted,
    );

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state is OrderCompleteState', () {
      when(
        () => orderRepository.orderStream(any()),
      ).thenAnswer((_) => const Stream.empty());
      expect(
        OrderCompleteBloc(orderRepository: orderRepository).state,
        const OrderCompleteState(),
      );
    });

    group('OrderCompleteSubscriptionRequested', () {
      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits success with order data',
        build: () {
          when(
            () => orderRepository.orderStream(orderId),
          ).thenAnswer((_) => Stream.value(order));
          return OrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(
          const OrderCompleteSubscriptionRequested(orderId: orderId),
        ),
        expect: () => [
          const OrderCompleteState(
            status: OrderCompleteStatus.success,
            order: order,
          ),
        ],
      );

      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits failure on error',
        build: () {
          when(
            () => orderRepository.orderStream(orderId),
          ).thenAnswer((_) => Stream.error(Exception('error')));
          return OrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(
          const OrderCompleteSubscriptionRequested(orderId: orderId),
        ),
        expect: () => [
          const OrderCompleteState(status: OrderCompleteStatus.failure),
        ],
      );
    });

    group('OrderCompleteDoneRequested', () {
      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'calls clearCurrentOrder and emits navigatingBack',
        build: () {
          when(
            () => orderRepository.orderStream(any()),
          ).thenAnswer((_) => const Stream.empty());
          when(
            () => orderRepository.clearCurrentOrder(),
          ).thenAnswer((_) async {});
          return OrderCompleteBloc(orderRepository: orderRepository);
        },
        seed: () => const OrderCompleteState(
          status: OrderCompleteStatus.success,
          order: order,
        ),
        act: (bloc) => bloc.add(const OrderCompleteDoneRequested()),
        expect: () => [
          const OrderCompleteState(
            status: OrderCompleteStatus.navigatingBack,
            order: order,
          ),
        ],
        verify: (_) {
          verify(() => orderRepository.clearCurrentOrder()).called(1);
        },
      );
    });
  });
}
