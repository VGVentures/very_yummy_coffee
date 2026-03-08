import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/home/home.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Latte',
  price: 450,
);

const _pendingOrder = Order(
  id: 'order-abc-0001',
  items: [_testItem],
  status: OrderStatus.pending,
);

const _submittedOrder = Order(
  id: 'order-abc-0002',
  items: [_testItem],
  status: OrderStatus.submitted,
);

const _readyOrder = Order(
  id: 'order-abc-0003',
  items: [_testItem],
  status: OrderStatus.ready,
);

const _completedOrder = Order(
  id: 'order-abc-0004',
  items: [_testItem],
  status: OrderStatus.completed,
);

const _inProgressOrder = Order(
  id: 'order-abc-0006',
  items: [_testItem],
  status: OrderStatus.inProgress,
);

const _cancelledOrder = Order(
  id: 'order-abc-0005',
  items: [_testItem],
  status: OrderStatus.cancelled,
);

void main() {
  group('HomeBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    HomeBloc buildBloc() => HomeBloc(orderRepository: orderRepository);

    test('initial state is HomeState(status: loading, orders: [])', () {
      final bloc = buildBloc();
      expect(bloc.state, const HomeState());
      expect(bloc.state.status, HomeStatus.loading);
      expect(bloc.state.orders, isEmpty);
    });

    group('HomeSubscriptionRequested', () {
      blocTest<HomeBloc, HomeState>(
        'emits [success] with active orders when stream emits orders',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              const Orders(orders: [_pendingOrder, _submittedOrder]),
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const HomeSubscriptionRequested()),
        expect: () => [
          const HomeState(
            status: HomeStatus.success,
            orders: [_submittedOrder],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'includes inProgress orders in active list',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              const Orders(orders: [_inProgressOrder]),
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const HomeSubscriptionRequested()),
        expect: () => [
          const HomeState(
            status: HomeStatus.success,
            orders: [_inProgressOrder],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'includes ready orders in active list',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              const Orders(orders: [_readyOrder]),
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const HomeSubscriptionRequested()),
        expect: () => [
          const HomeState(
            status: HomeStatus.success,
            orders: [_readyOrder],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'filters out pending, completed, and cancelled orders',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              const Orders(
                orders: [
                  _pendingOrder,
                  _completedOrder,
                  _cancelledOrder,
                  _submittedOrder,
                ],
              ),
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const HomeSubscriptionRequested()),
        expect: () => [
          const HomeState(
            status: HomeStatus.success,
            orders: [_submittedOrder],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [success] with empty list when all orders are filtered out',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.value(
              const Orders(orders: [_completedOrder, _cancelledOrder]),
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const HomeSubscriptionRequested()),
        expect: () => [
          const HomeState(status: HomeStatus.success),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [failure] on stream error',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.error(Exception('connection lost')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const HomeSubscriptionRequested()),
        expect: () => [
          const HomeState(status: HomeStatus.failure),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'updates active orders on multiple stream emissions',
        build: () {
          when(() => orderRepository.ordersStream).thenAnswer(
            (_) => Stream.fromIterable([
              const Orders(orders: [_submittedOrder]),
              const Orders(
                orders: [_submittedOrder, _readyOrder],
              ),
            ]),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const HomeSubscriptionRequested()),
        expect: () => [
          const HomeState(
            status: HomeStatus.success,
            orders: [_submittedOrder],
          ),
          const HomeState(
            status: HomeStatus.success,
            orders: [_submittedOrder, _readyOrder],
          ),
        ],
      );
    });
  });
}
