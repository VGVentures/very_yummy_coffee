import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/checkout/checkout.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('CheckoutBloc', () {
    late OrderRepository orderRepository;
    const order = Order(
      id: 'order-1',
      items: [LineItem(id: 'a', name: 'Latte', price: 500)],
      status: OrderStatus.pending,
    );

    setUp(() {
      orderRepository = _MockOrderRepository();
    });

    test('initial state is CheckoutState', () {
      when(
        () => orderRepository.currentOrderStream,
      ).thenAnswer((_) => const Stream.empty());
      expect(
        CheckoutBloc(orderRepository: orderRepository).state,
        const CheckoutState(),
      );
    });

    group('CheckoutSubscriptionRequested', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'emits idle with order on success',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => Stream.value(order));
          return CheckoutBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CheckoutSubscriptionRequested()),
        expect: () => [
          const CheckoutState(status: CheckoutStatus.idle, order: order),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'emits failure on error',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => Stream.error(Exception('error')));
          return CheckoutBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CheckoutSubscriptionRequested()),
        expect: () => [
          const CheckoutState(status: CheckoutStatus.failure),
        ],
      );
    });

    group('CheckoutConfirmed', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'emits [submitting, success] on successful submission',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => const Stream.empty());
          when(() => orderRepository.submitCurrentOrder()).thenReturn(null);
          return CheckoutBloc(orderRepository: orderRepository);
        },
        seed: () =>
            const CheckoutState(status: CheckoutStatus.idle, order: order),
        act: (bloc) => bloc.add(const CheckoutConfirmed()),
        expect: () => [
          const CheckoutState(
            status: CheckoutStatus.submitting,
            order: order,
          ),
          const CheckoutState(
            status: CheckoutStatus.success,
            order: order,
          ),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'emits failure when order is null',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => const Stream.empty());
          return CheckoutBloc(orderRepository: orderRepository);
        },
        act: (bloc) => bloc.add(const CheckoutConfirmed()),
        expect: () => [
          const CheckoutState(status: CheckoutStatus.failure),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'calls updateNameOnCurrentOrder before submit when name is provided',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => const Stream.empty());
          when(() => orderRepository.submitCurrentOrder()).thenReturn(null);
          when(
            () => orderRepository.updateNameOnCurrentOrder(any()),
          ).thenAnswer((_) async {});
          return CheckoutBloc(orderRepository: orderRepository);
        },
        seed: () =>
            const CheckoutState(status: CheckoutStatus.idle, order: order),
        act: (bloc) =>
            bloc.add(const CheckoutConfirmed(customerName: 'Marcus')),
        expect: () => [
          const CheckoutState(
            status: CheckoutStatus.submitting,
            order: order,
          ),
          const CheckoutState(
            status: CheckoutStatus.success,
            order: order,
          ),
        ],
        verify: (_) {
          verify(
            () => orderRepository.updateNameOnCurrentOrder('Marcus'),
          ).called(1);
          verify(() => orderRepository.submitCurrentOrder()).called(1);
        },
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'skips updateNameOnCurrentOrder when name is empty',
        build: () {
          when(
            () => orderRepository.currentOrderStream,
          ).thenAnswer((_) => const Stream.empty());
          when(() => orderRepository.submitCurrentOrder()).thenReturn(null);
          return CheckoutBloc(orderRepository: orderRepository);
        },
        seed: () =>
            const CheckoutState(status: CheckoutStatus.idle, order: order),
        act: (bloc) => bloc.add(const CheckoutConfirmed()),
        expect: () => [
          const CheckoutState(
            status: CheckoutStatus.submitting,
            order: order,
          ),
          const CheckoutState(
            status: CheckoutStatus.success,
            order: order,
          ),
        ],
        verify: (_) {
          verifyNever(
            () => orderRepository.updateNameOnCurrentOrder(any()),
          );
          verify(() => orderRepository.submitCurrentOrder()).called(1);
        },
      );
    });
  });
}
