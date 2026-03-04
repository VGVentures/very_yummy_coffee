import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'order_complete_bloc.mapper.dart';
part 'order_complete_event.dart';
part 'order_complete_state.dart';

class OrderCompleteBloc extends Bloc<OrderCompleteEvent, OrderCompleteState> {
  OrderCompleteBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const OrderCompleteState()) {
    on<OrderCompleteSubscriptionRequested>(_onSubscriptionRequested);
    on<OrderCompleteNewOrderRequested>(_onNewOrderRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    OrderCompleteSubscriptionRequested event,
    Emitter<OrderCompleteState> emit,
  ) async {
    emit(const OrderCompleteState());
    await emit.forEach(
      _orderRepository.orderStream(event.orderId),
      onData: (order) {
        if (order == null) {
          return state.status == OrderCompleteStatus.success
              ? state.copyWith(status: OrderCompleteStatus.failure)
              : state;
        }
        return state.copyWith(
          status: OrderCompleteStatus.success,
          order: order,
        );
      },
      onError: (_, _) => state.copyWith(status: OrderCompleteStatus.failure),
    );
  }

  void _onNewOrderRequested(
    OrderCompleteNewOrderRequested event,
    Emitter<OrderCompleteState> emit,
  ) {
    emit(state.copyWith(status: OrderCompleteStatus.navigatingAway));
  }
}
