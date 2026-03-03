import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/kds.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Latte',
  price: 450,
  options: 'Large',
);

final _submittedAt = DateTime(2026, 3, 1, 10);

final _submittedOrder = Order(
  id: 'order-1111',
  items: const [_testItem],
  status: OrderStatus.submitted,
  submittedAt: _submittedAt,
);

final _olderSubmittedOrder = Order(
  id: 'order-0000',
  items: const [_testItem],
  status: OrderStatus.submitted,
  submittedAt: _submittedAt.subtract(const Duration(minutes: 5)),
);

final _inProgressOrder = Order(
  id: 'order-2222',
  items: const [_testItem],
  status: OrderStatus.inProgress,
  submittedAt: _submittedAt,
);

final _readyOrder = Order(
  id: 'order-3333',
  items: const [_testItem],
  status: OrderStatus.ready,
  submittedAt: _submittedAt,
);

void main() {
  group('KdsBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    KdsBloc buildBloc() => KdsBloc(orderRepository: orderRepository);

    test('initial state has KdsStatus.initial and empty order lists', () {
      when(() => orderRepository.ordersStream).thenAnswer(
        (_) => const Stream.empty(),
      );
      final bloc = buildBloc();
      expect(bloc.state.status, KdsStatus.initial);
      expect(bloc.state.newOrders, isEmpty);
      expect(bloc.state.inProgressOrders, isEmpty);
      expect(bloc.state.readyOrders, isEmpty);
    });

    group('KdsSubscriptionRequested', () {
      blocTest<KdsBloc, KdsState>(
        'emits [loading, success] with orders split by status',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              Orders(orders: [_submittedOrder, _inProgressOrder, _readyOrder]),
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const KdsSubscriptionRequested()),
        expect: () => [
          const KdsState(status: KdsStatus.loading),
          KdsState(
            status: KdsStatus.success,
            newOrders: [_submittedOrder],
            inProgressOrders: [_inProgressOrder],
            readyOrders: [_readyOrder],
          ),
        ],
      );

      blocTest<KdsBloc, KdsState>(
        'sorts orders oldest-first within each column',
        build: () {
          // _submittedOrder is newer than _olderSubmittedOrder
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              Orders(orders: [_submittedOrder, _olderSubmittedOrder]),
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const KdsSubscriptionRequested()),
        verify: (bloc) {
          final newOrders = bloc.state.newOrders;
          expect(newOrders.length, 2);
          expect(
            newOrders[0].submittedAt!.isBefore(newOrders[1].submittedAt!),
            isTrue,
          );
        },
      );

      blocTest<KdsBloc, KdsState>(
        'inProgress orders appear in inProgressOrders, not newOrders',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(Orders(orders: [_inProgressOrder])),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const KdsSubscriptionRequested()),
        verify: (bloc) {
          expect(bloc.state.newOrders, isEmpty);
          expect(bloc.state.inProgressOrders, [_inProgressOrder]);
        },
      );

      blocTest<KdsBloc, KdsState>(
        'emits [loading, failure] on stream error',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.error(Exception('connection lost')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const KdsSubscriptionRequested()),
        expect: () => [
          const KdsState(status: KdsStatus.loading),
          const KdsState(status: KdsStatus.failure),
        ],
      );
    });

    group('KdsOrderStarted', () {
      blocTest<KdsBloc, KdsState>(
        'calls orderRepository.startOrder with correct orderId',
        setUp: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(() => orderRepository.startOrder(any())).thenReturn(null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(KdsOrderStarted(_submittedOrder.id)),
        expect: () => <KdsState>[],
        verify: (_) => verify(
          () => orderRepository.startOrder(_submittedOrder.id),
        ).called(1),
      );
    });

    group('KdsOrderMarkedReady', () {
      blocTest<KdsBloc, KdsState>(
        'calls orderRepository.markOrderReady with correct orderId',
        setUp: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(() => orderRepository.markOrderReady(any())).thenReturn(null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(KdsOrderMarkedReady(_inProgressOrder.id)),
        expect: () => <KdsState>[],
        verify: (_) => verify(
          () => orderRepository.markOrderReady(_inProgressOrder.id),
        ).called(1),
      );
    });

    group('KdsOrderCompleted', () {
      blocTest<KdsBloc, KdsState>(
        'calls orderRepository.markOrderCompleted with correct orderId',
        setUp: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(
            () => orderRepository.markOrderCompleted(any()),
          ).thenReturn(null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(KdsOrderCompleted(_readyOrder.id)),
        expect: () => <KdsState>[],
        verify: (_) => verify(
          () => orderRepository.markOrderCompleted(_readyOrder.id),
        ).called(1),
      );
    });

    group('KdsOrderCancelled', () {
      blocTest<KdsBloc, KdsState>(
        'calls orderRepository.cancelOrder with correct orderId',
        setUp: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(() => orderRepository.cancelOrder(any())).thenReturn(null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(KdsOrderCancelled(_submittedOrder.id)),
        expect: () => <KdsState>[],
        verify: (_) => verify(
          () => orderRepository.cancelOrder(_submittedOrder.id),
        ).called(1),
      );
    });
  });
}
