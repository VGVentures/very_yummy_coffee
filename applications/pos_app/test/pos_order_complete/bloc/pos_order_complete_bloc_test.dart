import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/pos_order_complete/bloc/pos_order_complete_bloc.dart';

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

  group('PosOrderCompleteBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state is PosOrderCompleteState with loading status', () {
      expect(
        PosOrderCompleteBloc(orderRepository: orderRepository).state,
        const PosOrderCompleteState(),
      );
    });

    group('PosOrderCompleteSubscriptionRequested', () {
      blocTest<PosOrderCompleteBloc, PosOrderCompleteState>(
        'emits success with order when orderStream emits a non-null order',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream.value(tOrder),
          );
          return PosOrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const PosOrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const PosOrderCompleteState(),
          const PosOrderCompleteState(
            status: PosOrderCompleteStatus.success,
            order: tOrder,
          ),
        ],
      );

      blocTest<PosOrderCompleteBloc, PosOrderCompleteState>(
        'emits failure when orderStream emits null after success',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream.fromIterable([tOrder, null]),
          );
          return PosOrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const PosOrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const PosOrderCompleteState(),
          const PosOrderCompleteState(
            status: PosOrderCompleteStatus.success,
            order: tOrder,
          ),
          const PosOrderCompleteState(
            status: PosOrderCompleteStatus.failure,
            order: tOrder,
          ),
        ],
      );

      blocTest<PosOrderCompleteBloc, PosOrderCompleteState>(
        'stays loading when orderStream emits null without prior success',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream.value(null),
          );
          return PosOrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const PosOrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const PosOrderCompleteState(),
        ],
      );

      blocTest<PosOrderCompleteBloc, PosOrderCompleteState>(
        'emits failure on stream error',
        build: () {
          when(() => orderRepository.orderStream(tOrderId)).thenAnswer(
            (_) => Stream<Order?>.error(Exception('ws error')),
          );
          return PosOrderCompleteBloc(orderRepository: orderRepository);
        },
        act: (bloc) =>
            bloc.add(const PosOrderCompleteSubscriptionRequested(tOrderId)),
        expect: () => [
          const PosOrderCompleteState(),
          const PosOrderCompleteState(status: PosOrderCompleteStatus.failure),
        ],
      );
    });

    group('PosOrderCompleteNewOrderRequested', () {
      blocTest<PosOrderCompleteBloc, PosOrderCompleteState>(
        'emits navigatingAway status',
        build: () => PosOrderCompleteBloc(orderRepository: orderRepository),
        seed: () => const PosOrderCompleteState(
          status: PosOrderCompleteStatus.success,
          order: tOrder,
        ),
        act: (bloc) => bloc.add(const PosOrderCompleteNewOrderRequested()),
        expect: () => [
          const PosOrderCompleteState(
            status: PosOrderCompleteStatus.navigatingAway,
            order: tOrder,
          ),
        ],
      );
    });
  });
}
