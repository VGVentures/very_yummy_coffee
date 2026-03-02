import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/checkout/checkout.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Espresso',
  price: 300,
  options: 'Medium',
);

const _testOrder = Order(
  id: 'order-abc-1234',
  items: [_testItem],
  status: OrderStatus.pending,
);

void main() {
  group('CheckoutBloc', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
      when(() => orderRepository.submitCurrentOrder()).thenReturn(null);
    });

    CheckoutBloc buildBloc() => CheckoutBloc(orderRepository: orderRepository);

    test('initial state is CheckoutState(status: loading)', () {
      expect(buildBloc().state, const CheckoutState());
      expect(buildBloc().state.status, CheckoutStatus.loading);
    });

    group('CheckoutSubscriptionRequested', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'emits [idle with order] when stream emits non-null order',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(_testOrder),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CheckoutSubscriptionRequested()),
        expect: () => [
          const CheckoutState(
            order: _testOrder,
            status: CheckoutStatus.idle,
          ),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'emits [failure] when stream emits null (no active order)',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(null),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CheckoutSubscriptionRequested()),
        expect: () => [
          const CheckoutState(status: CheckoutStatus.failure),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'emits [failure] on stream error',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.error(Exception('oops')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CheckoutSubscriptionRequested()),
        expect: () => [
          const CheckoutState(status: CheckoutStatus.failure),
        ],
      );
    });

    group('CheckoutConfirmed', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'emits [failure] when state.order is null (guard)',
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckoutConfirmed()),
        expect: () => [
          const CheckoutState(status: CheckoutStatus.failure),
        ],
        verify: (_) => verifyNever(
          () => orderRepository.submitCurrentOrder(),
        ),
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'emits [submitting, success] when order is loaded',
        build: () {
          when(() => orderRepository.currentOrderStream).thenAnswer(
            (_) => Stream.value(_testOrder),
          );
          return buildBloc();
        },
        seed: () => const CheckoutState(
          order: _testOrder,
          status: CheckoutStatus.idle,
        ),
        act: (bloc) => bloc.add(const CheckoutConfirmed()),
        expect: () => [
          const CheckoutState(
            order: _testOrder,
            status: CheckoutStatus.submitting,
          ),
          const CheckoutState(
            order: _testOrder,
            status: CheckoutStatus.success,
          ),
        ],
        verify: (_) => verify(
          () => orderRepository.submitCurrentOrder(),
        ).called(1),
      );
    });
  });
}
