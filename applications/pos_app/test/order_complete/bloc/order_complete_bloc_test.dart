import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_complete/order_complete.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  const tOrderId = 'order-123';
  const tOrder = Order(
    id: tOrderId,
    status: OrderStatus.submitted,
    items: [
      LineItem(id: 'li1', name: 'Latte', price: 550),
    ],
  );

  group('OrderCompleteBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state is OrderCompleteState with loading status', () {
      expect(
        OrderCompleteBloc(orderRepository: orderRepository).state,
        const OrderCompleteState(),
      );
    });

    group('OrderCompleteSubscriptionRequested', () {
      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits success with order when orderStream emits a non-null order',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream.value(tOrder),
          );
          return OrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const OrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const OrderCompleteState(),
          const OrderCompleteState(
            status: OrderCompleteStatus.success,
            order: tOrder,
          ),
        ],
      );

      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits failure when orderStream emits null after success',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream.fromIterable([tOrder, null]),
          );
          return OrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const OrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const OrderCompleteState(),
          const OrderCompleteState(
            status: OrderCompleteStatus.success,
            order: tOrder,
          ),
          const OrderCompleteState(
            status: OrderCompleteStatus.failure,
            order: tOrder,
          ),
        ],
      );

      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'stays loading when orderStream emits null without prior success',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream.value(null),
          );
          return OrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const OrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const OrderCompleteState(),
        ],
      );

      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits failure on stream error',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream<Order?>.error(Exception('ws error')),
          );
          return OrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const OrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const OrderCompleteState(),
          const OrderCompleteState(status: OrderCompleteStatus.failure),
        ],
      );
    });

    group('OrderCompleteNewOrderRequested', () {
      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits navigatingAway status',
        build: () => OrderCompleteBloc(orderRepository: orderRepository),
        seed: () => const OrderCompleteState(
          status: OrderCompleteStatus.success,
          order: tOrder,
        ),
        act: (bloc) => bloc.add(const OrderCompleteNewOrderRequested()),
        expect: () => [
          const OrderCompleteState(
            status: OrderCompleteStatus.navigatingAway,
            order: tOrder,
          ),
        ],
      );
    });
  });
}
