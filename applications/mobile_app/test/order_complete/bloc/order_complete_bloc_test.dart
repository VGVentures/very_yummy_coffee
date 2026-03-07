import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/order_complete/order_complete.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Latte',
  price: 450,
);

const _testOrder = Order(
  id: 'order-xyz-5678',
  items: [_testItem],
  status: OrderStatus.pending,
);

void main() {
  group('OrderCompleteBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    OrderCompleteBloc buildBloc() =>
        OrderCompleteBloc(orderRepository: orderRepository);

    test('initial state is OrderCompleteState(status: loading)', () {
      expect(buildBloc().state, const OrderCompleteState());
      expect(buildBloc().state.status, OrderCompleteStatus.loading);
    });

    group('OrderCompleteSubscriptionRequested', () {
      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits [success with order] when stream emits order',
        build: () {
          when(
            () => orderRepository.orderStream('order-xyz-5678'),
          ).thenAnswer((_) => Stream.value(_testOrder));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const OrderCompleteSubscriptionRequested(
            orderId: 'order-xyz-5678',
          ),
        ),
        expect: () => [
          const OrderCompleteState(
            order: _testOrder,
            status: OrderCompleteStatus.success,
          ),
        ],
      );

      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits [failure] when stream emits null',
        build: () {
          when(
            () => orderRepository.orderStream('order-xyz-5678'),
          ).thenAnswer((_) => Stream.value(null));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const OrderCompleteSubscriptionRequested(
            orderId: 'order-xyz-5678',
          ),
        ),
        expect: () => [
          const OrderCompleteState(status: OrderCompleteStatus.failure),
        ],
      );

      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'emits [failure] on stream error',
        build: () {
          when(
            () => orderRepository.orderStream('order-xyz-5678'),
          ).thenAnswer((_) => Stream.error(Exception('oops')));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const OrderCompleteSubscriptionRequested(
            orderId: 'order-xyz-5678',
          ),
        ),
        expect: () => [
          const OrderCompleteState(status: OrderCompleteStatus.failure),
        ],
      );

      blocTest<OrderCompleteBloc, OrderCompleteState>(
        'updates order state on multiple stream emissions',
        build: () {
          const updatedOrder = Order(
            id: 'order-xyz-5678',
            items: [_testItem],
            status: OrderStatus.submitted,
          );
          when(() => orderRepository.orderStream('order-xyz-5678')).thenAnswer(
            (_) => Stream.fromIterable([_testOrder, updatedOrder]),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const OrderCompleteSubscriptionRequested(
            orderId: 'order-xyz-5678',
          ),
        ),
        expect: () => [
          const OrderCompleteState(
            order: _testOrder,
            status: OrderCompleteStatus.success,
          ),
          const OrderCompleteState(
            order: Order(
              id: 'order-xyz-5678',
              items: [_testItem],
              status: OrderStatus.submitted,
            ),
            status: OrderCompleteStatus.success,
          ),
        ],
      );
    });
  });
}
