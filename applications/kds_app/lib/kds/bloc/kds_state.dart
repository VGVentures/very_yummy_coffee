part of 'kds_bloc.dart';

@MappableEnum()
enum KdsStatus { initial, loading, success, failure }

@MappableClass()
class KdsState with KdsStateMappable {
  const KdsState({
    this.status = KdsStatus.initial,
    this.pendingOrders = const [],
    this.newOrders = const [],
    this.inProgressOrders = const [],
    this.readyOrders = const [],
  });

  final KdsStatus status;

  /// Orders with status [OrderStatus.pending] — still being built by customer.
  final List<Order> pendingOrders;

  /// Orders with status [OrderStatus.submitted] — awaiting kitchen start.
  final List<Order> newOrders;

  /// Orders with status [OrderStatus.inProgress] — actively being prepared.
  final List<Order> inProgressOrders;

  /// Orders with status [OrderStatus.ready] — ready for pickup.
  final List<Order> readyOrders;
}
