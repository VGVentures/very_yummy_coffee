import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'pos_orders_bloc.mapper.dart';
part 'pos_orders_event.dart';
part 'pos_orders_state.dart';

class PosOrdersBloc extends Bloc<PosOrdersEvent, PosOrdersState> {
  PosOrdersBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const PosOrdersState()) {
    on<PosOrdersSubscriptionRequested>(_onSubscriptionRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    PosOrdersSubscriptionRequested event,
    Emitter<PosOrdersState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.ordersStream,
      onData: (orders) {
        final active = orders.orders
            .where(
              (o) =>
                  o.status == OrderStatus.submitted ||
                  o.status == OrderStatus.inProgress ||
                  o.status == OrderStatus.ready,
            )
            .toList();
        final history = orders.orders
            .where(
              (o) =>
                  o.status == OrderStatus.completed ||
                  o.status == OrderStatus.cancelled,
            )
            .toList();
        return state.copyWith(
          status: PosOrdersStatus.success,
          activeOrders: active,
          historyOrders: history,
        );
      },
      onError: (_, _) => state.copyWith(status: PosOrdersStatus.failure),
    );
  }
}
