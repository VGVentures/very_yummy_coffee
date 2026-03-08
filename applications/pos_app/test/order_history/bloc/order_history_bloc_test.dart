import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_history/order_history.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  const tSubmittedOrder = Order(
    id: 'order-1',
    status: OrderStatus.submitted,
    items: [],
  );
  const tInProgressOrder = Order(
    id: 'order-2',
    status: OrderStatus.inProgress,
    items: [],
  );
  const tReadyOrder = Order(
    id: 'order-3',
    status: OrderStatus.ready,
    items: [],
  );
  const tCompletedOrder = Order(
    id: 'order-4',
    status: OrderStatus.completed,
    items: [],
  );
  const tCancelledOrder = Order(
    id: 'order-5',
    status: OrderStatus.cancelled,
    items: [],
  );
  const tPendingOrder = Order(
    id: 'order-6',
    status: OrderStatus.pending,
    items: [LineItem(id: 'li-p', name: 'Espresso', price: 350)],
  );
  const tEmptyPendingOrder = Order(
    id: 'order-7',
    status: OrderStatus.pending,
    items: [],
  );

  group('OrderHistoryBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state is OrderHistoryState with loading status', () {
      when(() => orderRepository.ordersStream).thenAnswer(
        (_) => const Stream.empty(),
      );
      expect(
        OrderHistoryBloc(orderRepository: orderRepository).state,
        const OrderHistoryState(),
      );
    });

    group('OrderHistorySubscriptionRequested', () {
      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'emits success with active and history orders filtered correctly',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              const Orders(
                orders: [
                  tSubmittedOrder,
                  tInProgressOrder,
                  tReadyOrder,
                  tCompletedOrder,
                  tCancelledOrder,
                  tPendingOrder,
                ],
              ),
            ),
          );
          return OrderHistoryBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderHistorySubscriptionRequested()),
        expect: () => [
          const OrderHistoryState(
            status: OrderHistoryStatus.success,
            pendingOrders: [tPendingOrder],
            activeOrders: [tSubmittedOrder, tInProgressOrder, tReadyOrder],
            historyOrders: [tCompletedOrder, tCancelledOrder],
          ),
        ],
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'pending order moves to activeOrders when submitted',
        build: () {
          const submittedVersion = Order(
            id: 'order-6',
            status: OrderStatus.submitted,
            items: [],
          );
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.fromIterable([
              const Orders(orders: [tPendingOrder]),
              const Orders(orders: [submittedVersion]),
            ]),
          );
          return OrderHistoryBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderHistorySubscriptionRequested()),
        verify: (bloc) {
          expect(bloc.state.pendingOrders, isEmpty);
          expect(bloc.state.activeOrders, hasLength(1));
          expect(bloc.state.activeOrders.first.id, tPendingOrder.id);
        },
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'excludes pending orders with no items',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              const Orders(orders: [tEmptyPendingOrder, tPendingOrder]),
            ),
          );
          return OrderHistoryBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderHistorySubscriptionRequested()),
        verify: (bloc) {
          expect(bloc.state.pendingOrders, [tPendingOrder]);
        },
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'emits success with empty lists when no orders',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(const Orders(orders: [])),
          );
          return OrderHistoryBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderHistorySubscriptionRequested()),
        expect: () => [
          const OrderHistoryState(status: OrderHistoryStatus.success),
        ],
      );

      blocTest<OrderHistoryBloc, OrderHistoryState>(
        'emits failure on stream error',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream<Orders>.error(Exception('ws error')),
          );
          return OrderHistoryBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderHistorySubscriptionRequested()),
        expect: () => [
          const OrderHistoryState(status: OrderHistoryStatus.failure),
        ],
      );
    });
  });
}
