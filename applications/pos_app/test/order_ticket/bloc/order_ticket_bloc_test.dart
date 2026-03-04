import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  const tOrderId = 'order-123';
  const tOrder = Order(
    id: tOrderId,
    status: OrderStatus.pending,
    items: [
      LineItem(id: 'li1', name: 'Latte', price: 550),
    ],
  );
  const tEmptyOrder = Order(
    id: tOrderId,
    status: OrderStatus.pending,
    items: [],
  );

  group('OrderTicketBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state is OrderTicketState with loading status', () {
      expect(
        OrderTicketBloc(orderRepository: orderRepository).state,
        const OrderTicketState(),
      );
    });

    group('OrderTicketSubscriptionRequested', () {
      blocTest<OrderTicketBloc, OrderTicketState>(
        'emits idle with order when currentOrderStream emits',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(tOrder),
          );
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderTicketSubscriptionRequested()),
        expect: () => [
          const OrderTicketState(
            status: OrderTicketStatus.idle,
            order: tOrder,
          ),
        ],
      );

      blocTest<OrderTicketBloc, OrderTicketState>(
        'emits failure on stream error',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.error(Exception('ws error')),
          );
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderTicketSubscriptionRequested()),
        expect: () => [
          const OrderTicketState(status: OrderTicketStatus.failure),
        ],
      );
    });

    group('OrderTicketChargeRequested', () {
      blocTest<OrderTicketBloc, OrderTicketState>(
        'emits [charging, submitted] and calls submitCurrentOrder',
        build: () {
          when(() => orderRepository.currentOrderId).thenReturn(tOrderId);
          when(() => orderRepository.submitCurrentOrder()).thenReturn(null);
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        seed: () => const OrderTicketState(
          status: OrderTicketStatus.idle,
          order: tOrder,
        ),
        act: (bloc) => bloc.add(const OrderTicketChargeRequested()),
        expect: () => [
          const OrderTicketState(
            status: OrderTicketStatus.charging,
            order: tOrder,
          ),
          const OrderTicketState(
            status: OrderTicketStatus.submitted,
            order: tOrder,
            submittedOrderId: tOrderId,
          ),
        ],
        verify: (_) {
          verify(() => orderRepository.submitCurrentOrder()).called(1);
        },
      );

      blocTest<OrderTicketBloc, OrderTicketState>(
        'no-ops when already charging',
        build: () {
          when(() => orderRepository.currentOrderId).thenReturn(tOrderId);
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        seed: () => const OrderTicketState(
          status: OrderTicketStatus.charging,
          order: tOrder,
        ),
        act: (bloc) => bloc.add(const OrderTicketChargeRequested()),
        expect: () => <OrderTicketState>[],
      );

      blocTest<OrderTicketBloc, OrderTicketState>(
        'no-ops when order is empty',
        build: () {
          when(() => orderRepository.currentOrderId).thenReturn(tOrderId);
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        seed: () => const OrderTicketState(
          status: OrderTicketStatus.idle,
          order: tEmptyOrder,
        ),
        act: (bloc) => bloc.add(const OrderTicketChargeRequested()),
        expect: () => <OrderTicketState>[],
      );
    });

    group('OrderTicketClearRequested', () {
      blocTest<OrderTicketBloc, OrderTicketState>(
        'calls clearCurrentOrder and emits idle with null order',
        build: () {
          when(() => orderRepository.clearCurrentOrder()).thenReturn(null);
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        seed: () => const OrderTicketState(
          status: OrderTicketStatus.idle,
          order: tOrder,
        ),
        act: (bloc) => bloc.add(const OrderTicketClearRequested()),
        expect: () => [
          const OrderTicketState(
            status: OrderTicketStatus.idle,
          ),
        ],
        verify: (_) {
          verify(() => orderRepository.clearCurrentOrder()).called(1);
        },
      );
    });

    group('OrderTicketCreateOrderRequested', () {
      blocTest<OrderTicketBloc, OrderTicketState>(
        'calls createOrder when no current order',
        build: () {
          when(() => orderRepository.currentOrderId).thenReturn(null);
          when(() => orderRepository.createOrder()).thenAnswer((_) async {});
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderTicketCreateOrderRequested()),
        expect: () => [
          const OrderTicketState(),
        ],
        verify: (_) {
          verify(() => orderRepository.createOrder()).called(1);
        },
      );

      blocTest<OrderTicketBloc, OrderTicketState>(
        'no-ops when order already exists',
        build: () {
          when(() => orderRepository.currentOrderId).thenReturn(tOrderId);
          return OrderTicketBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const OrderTicketCreateOrderRequested()),
        expect: () => <OrderTicketState>[],
      );
    });
  });
}
