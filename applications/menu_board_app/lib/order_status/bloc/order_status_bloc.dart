import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'order_status_bloc.mapper.dart';
part 'order_status_event.dart';
part 'order_status_state.dart';

class OrderStatusBloc extends Bloc<OrderStatusEvent, OrderStatusState> {
  OrderStatusBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const OrderStatusState()) {
    on<OrderStatusSubscriptionRequested>(_onSubscriptionRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    OrderStatusSubscriptionRequested event,
    Emitter<OrderStatusState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatusStatus.loading));
    await emit.forEach(
      _orderRepository.ordersStream,
      onData: (orders) {
        final sorted = List<Order>.from(orders.orders)
          ..sort((a, b) {
            final aTime = a.submittedAt;
            final bTime = b.submittedAt;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return aTime.compareTo(bTime);
          });

        return state.copyWith(
          status: OrderStatusStatus.success,
          inProgressOrders: sorted
              .where((o) => o.status == OrderStatus.inProgress)
              .toList(),
          readyOrders: sorted
              .where((o) => o.status == OrderStatus.ready)
              .toList(),
        );
      },
      onError: (_, _) => state.copyWith(status: OrderStatusStatus.failure),
    );
  }
}
