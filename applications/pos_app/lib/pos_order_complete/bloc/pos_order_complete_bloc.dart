import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'pos_order_complete_bloc.mapper.dart';
part 'pos_order_complete_event.dart';
part 'pos_order_complete_state.dart';

class PosOrderCompleteBloc
    extends Bloc<PosOrderCompleteEvent, PosOrderCompleteState> {
  PosOrderCompleteBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const PosOrderCompleteState()) {
    on<PosOrderCompleteSubscriptionRequested>(_onSubscriptionRequested);
    on<PosOrderCompleteNewOrderRequested>(_onNewOrderRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    PosOrderCompleteSubscriptionRequested event,
    Emitter<PosOrderCompleteState> emit,
  ) async {
    emit(const PosOrderCompleteState());
    await emit.forEach(
      _orderRepository.orderStream(event.orderId),
      onData: (order) {
        if (order == null) {
          return state.status == PosOrderCompleteStatus.success
              ? state.copyWith(status: PosOrderCompleteStatus.failure)
              : state;
        }
        return state.copyWith(
          status: PosOrderCompleteStatus.success,
          order: order,
        );
      },
      onError: (_, _) =>
          state.copyWith(status: PosOrderCompleteStatus.failure),
    );
  }

  void _onNewOrderRequested(
    PosOrderCompleteNewOrderRequested event,
    Emitter<PosOrderCompleteState> emit,
  ) {
    emit(state.copyWith(status: PosOrderCompleteStatus.navigatingAway));
  }
}
