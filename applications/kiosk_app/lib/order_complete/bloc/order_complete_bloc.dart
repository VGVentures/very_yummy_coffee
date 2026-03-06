import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'order_complete_bloc.mapper.dart';
part 'order_complete_event.dart';
part 'order_complete_state.dart';

class OrderCompleteBloc extends Bloc<OrderCompleteEvent, OrderCompleteState> {
  OrderCompleteBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const OrderCompleteState()) {
    on<OrderCompleteSubscriptionRequested>(_onSubscriptionRequested);
    on<OrderCompleteDoneRequested>(_onDoneRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    OrderCompleteSubscriptionRequested event,
    Emitter<OrderCompleteState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.orderStream(event.orderId),
      onData: (order) => order == null
          ? state.copyWith(status: OrderCompleteStatus.failure)
          : state.copyWith(order: order, status: OrderCompleteStatus.success),
      onError: (_, _) => state.copyWith(status: OrderCompleteStatus.failure),
    );
  }

  void _onDoneRequested(
    OrderCompleteDoneRequested event,
    Emitter<OrderCompleteState> emit,
  ) {
    _orderRepository.clearCurrentOrder();
    emit(state.copyWith(status: OrderCompleteStatus.navigatingBack));
  }
}
