import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'checkout_bloc.mapper.dart';
part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const CheckoutState()) {
    on<CheckoutSubscriptionRequested>(_onSubscriptionRequested);
    on<CheckoutConfirmed>(_onCheckoutConfirmed);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    CheckoutSubscriptionRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.currentOrderStream,
      onData: (order) => order == null
          ? state.copyWith(status: CheckoutStatus.failure)
          : state.copyWith(order: order, status: CheckoutStatus.idle),
      onError: (_, _) => state.copyWith(status: CheckoutStatus.failure),
    );
  }

  Future<void> _onCheckoutConfirmed(
    CheckoutConfirmed event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state.order == null) {
      emit(state.copyWith(status: CheckoutStatus.failure));
      return;
    }
    emit(state.copyWith(status: CheckoutStatus.submitting));
    _orderRepository.submitCurrentOrder();
    emit(state.copyWith(status: CheckoutStatus.success));
  }
}
