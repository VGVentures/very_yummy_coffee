import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/order_status/order_status.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late OrderRepository orderRepository;

  final now = DateTime(2026, 3, 9, 12);
  final earlier = DateTime(2026, 3, 9, 11);
  final later = DateTime(2026, 3, 9, 13);

  final inProgressOrder = Order(
    id: 'order-1',
    items: const [LineItem(id: 'li-1', name: 'Latte', price: 550)],
    status: OrderStatus.inProgress,
    customerName: 'Marcus',
    submittedAt: now,
  );

  final readyOrder = Order(
    id: 'order-2',
    items: const [LineItem(id: 'li-2', name: 'Espresso', price: 350)],
    status: OrderStatus.ready,
    customerName: 'Alice',
    submittedAt: earlier,
  );

  const pendingOrder = Order(
    id: 'order-3',
    items: [LineItem(id: 'li-3', name: 'Mocha', price: 600)],
    status: OrderStatus.pending,
  );

  final submittedOrder = Order(
    id: 'order-4',
    items: const [LineItem(id: 'li-4', name: 'Cappuccino', price: 500)],
    status: OrderStatus.submitted,
    submittedAt: now,
  );

  final completedOrder = Order(
    id: 'order-5',
    items: const [LineItem(id: 'li-5', name: 'Drip', price: 300)],
    status: OrderStatus.completed,
    submittedAt: earlier,
  );

  final cancelledOrder = Order(
    id: 'order-6',
    items: const [LineItem(id: 'li-6', name: 'Tea', price: 250)],
    status: OrderStatus.cancelled,
    submittedAt: earlier,
  );

  setUp(() {
    orderRepository = _MockOrderRepository();
    when(() => orderRepository.ordersStream).thenAnswer(
      (_) => const Stream.empty(),
    );
  });

  group('OrderStatusBloc', () {
    blocTest<OrderStatusBloc, OrderStatusState>(
      'emits loading then success on subscription',
      build: () {
        when(() => orderRepository.ordersStream).thenAnswer(
          (_) => Stream.value(Orders(orders: [inProgressOrder])),
        );
        return OrderStatusBloc(orderRepository: orderRepository);
      },
      act: (bloc) => bloc.add(const OrderStatusSubscriptionRequested()),
      expect: () => [
        const OrderStatusState(status: OrderStatusStatus.loading),
        OrderStatusState(
          status: OrderStatusStatus.success,
          inProgressOrders: [inProgressOrder],
        ),
      ],
    );

    blocTest<OrderStatusBloc, OrderStatusState>(
      'filters to only inProgress and ready orders',
      build: () {
        when(() => orderRepository.ordersStream).thenAnswer(
          (_) => Stream.value(
            Orders(
              orders: [
                inProgressOrder,
                readyOrder,
                pendingOrder,
                submittedOrder,
                completedOrder,
                cancelledOrder,
              ],
            ),
          ),
        );
        return OrderStatusBloc(orderRepository: orderRepository);
      },
      act: (bloc) => bloc.add(const OrderStatusSubscriptionRequested()),
      expect: () => [
        const OrderStatusState(status: OrderStatusStatus.loading),
        OrderStatusState(
          status: OrderStatusStatus.success,
          inProgressOrders: [inProgressOrder],
          readyOrders: [readyOrder],
        ),
      ],
    );

    blocTest<OrderStatusBloc, OrderStatusState>(
      'sorts by submittedAt oldest first',
      build: () {
        final laterInProgress = Order(
          id: 'order-later',
          items: const [LineItem(id: 'li-later', name: 'Latte', price: 550)],
          status: OrderStatus.inProgress,
          submittedAt: later,
        );
        final earlierInProgress = Order(
          id: 'order-earlier',
          items: const [
            LineItem(id: 'li-earlier', name: 'Espresso', price: 350),
          ],
          status: OrderStatus.inProgress,
          submittedAt: earlier,
        );
        when(() => orderRepository.ordersStream).thenAnswer(
          (_) => Stream.value(
            Orders(orders: [laterInProgress, earlierInProgress]),
          ),
        );
        return OrderStatusBloc(orderRepository: orderRepository);
      },
      act: (bloc) => bloc.add(const OrderStatusSubscriptionRequested()),
      expect: () => [
        const OrderStatusState(status: OrderStatusStatus.loading),
        isA<OrderStatusState>()
            .having((s) => s.status, 'status', OrderStatusStatus.success)
            .having(
              (s) => s.inProgressOrders.map((o) => o.id).toList(),
              'inProgressOrders ids',
              ['order-earlier', 'order-later'],
            ),
      ],
    );

    blocTest<OrderStatusBloc, OrderStatusState>(
      'handles null submittedAt by pushing to end',
      build: () {
        const noTimestamp = Order(
          id: 'order-no-time',
          items: [LineItem(id: 'li-no-time', name: 'Latte', price: 550)],
          status: OrderStatus.inProgress,
        );
        when(() => orderRepository.ordersStream).thenAnswer(
          (_) => Stream.value(
            Orders(orders: [noTimestamp, inProgressOrder]),
          ),
        );
        return OrderStatusBloc(orderRepository: orderRepository);
      },
      act: (bloc) => bloc.add(const OrderStatusSubscriptionRequested()),
      expect: () => [
        const OrderStatusState(status: OrderStatusStatus.loading),
        isA<OrderStatusState>()
            .having((s) => s.status, 'status', OrderStatusStatus.success)
            .having(
              (s) => s.inProgressOrders.map((o) => o.id).toList(),
              'inProgressOrders ids',
              ['order-1', 'order-no-time'],
            ),
      ],
    );

    blocTest<OrderStatusBloc, OrderStatusState>(
      'handles empty orders list',
      build: () {
        when(() => orderRepository.ordersStream).thenAnswer(
          (_) => Stream.value(const Orders(orders: [])),
        );
        return OrderStatusBloc(orderRepository: orderRepository);
      },
      act: (bloc) => bloc.add(const OrderStatusSubscriptionRequested()),
      expect: () => [
        const OrderStatusState(status: OrderStatusStatus.loading),
        const OrderStatusState(status: OrderStatusStatus.success),
      ],
    );

    blocTest<OrderStatusBloc, OrderStatusState>(
      'emits failure on stream error',
      build: () {
        when(() => orderRepository.ordersStream).thenAnswer(
          (_) => Stream.error(Exception('connection lost')),
        );
        return OrderStatusBloc(orderRepository: orderRepository);
      },
      act: (bloc) => bloc.add(const OrderStatusSubscriptionRequested()),
      expect: () => [
        const OrderStatusState(status: OrderStatusStatus.loading),
        const OrderStatusState(status: OrderStatusStatus.failure),
      ],
    );
  });
}
