import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'order_history_bloc.mapper.dart';
part 'order_history_event.dart';
part 'order_history_state.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  OrderHistoryBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const OrderHistoryState()) {
    on<OrderHistorySubscriptionRequested>(_onSubscriptionRequested);
    on<OrderHistoryOrderStarted>(
      (event, _) => _orderRepository.startOrder(event.orderId),
    );
    on<OrderHistoryOrderMarkedReady>(
      (event, _) => _orderRepository.markOrderReady(event.orderId),
    );
    on<OrderHistoryOrderCompleted>(
      (event, _) => _orderRepository.markOrderCompleted(event.orderId),
    );
    on<OrderHistoryOrderCancelled>(
      (event, _) => _orderRepository.cancelOrder(event.orderId),
    );
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    OrderHistorySubscriptionRequested event,
    Emitter<OrderHistoryState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.ordersStream,
      onData: (orders) {
        final pending = orders.orders
            .where(
              (o) => o.status == OrderStatus.pending && o.items.isNotEmpty,
            )
            .toList();
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
          status: OrderHistoryStatus.success,
          pendingOrders: pending,
          activeOrders: active,
          historyOrders: history,
        );
      },
      onError: (_, _) => state.copyWith(status: OrderHistoryStatus.failure),
    );
  }
}
