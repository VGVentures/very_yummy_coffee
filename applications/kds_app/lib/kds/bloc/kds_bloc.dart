import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'kds_bloc.mapper.dart';
part 'kds_event.dart';
part 'kds_state.dart';

/// {@template kds_bloc}
/// Manages the KDS display state by subscribing to the [OrderRepository]
/// orders stream and dispatching kitchen actions (start, ready, complete,
/// cancel) via WebSocket.
/// {@endtemplate}
class KdsBloc extends Bloc<KdsEvent, KdsState> {
  KdsBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const KdsState()) {
    on<KdsSubscriptionRequested>(_onSubscriptionRequested);
    on<KdsOrderStarted>(_onOrderStarted);
    on<KdsOrderMarkedReady>(_onOrderMarkedReady);
    on<KdsOrderCompleted>(_onOrderCompleted);
    on<KdsOrderCancelled>(_onOrderCancelled);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    KdsSubscriptionRequested event,
    Emitter<KdsState> emit,
  ) async {
    emit(state.copyWith(status: KdsStatus.loading));
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
          status: KdsStatus.success,
          newOrders: sorted
              .where((o) => o.status == OrderStatus.submitted)
              .toList(),
          inProgressOrders: sorted
              .where((o) => o.status == OrderStatus.inProgress)
              .toList(),
          readyOrders: sorted
              .where((o) => o.status == OrderStatus.ready)
              .toList(),
        );
      },
      onError: (_, _) => state.copyWith(status: KdsStatus.failure),
    );
  }

  void _onOrderStarted(KdsOrderStarted event, Emitter<KdsState> emit) {
    _orderRepository.startOrder(event.orderId);
  }

  void _onOrderMarkedReady(
    KdsOrderMarkedReady event,
    Emitter<KdsState> emit,
  ) {
    _orderRepository.markOrderReady(event.orderId);
  }

  void _onOrderCompleted(KdsOrderCompleted event, Emitter<KdsState> emit) {
    _orderRepository.markOrderCompleted(event.orderId);
  }

  void _onOrderCancelled(KdsOrderCancelled event, Emitter<KdsState> emit) {
    _orderRepository.cancelOrder(event.orderId);
  }
}
