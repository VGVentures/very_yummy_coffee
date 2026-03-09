part of 'order_status_bloc.dart';

@MappableEnum()
enum OrderStatusStatus { initial, loading, success, failure }

@MappableClass()
class OrderStatusState with OrderStatusStateMappable {
  const OrderStatusState({
    this.status = OrderStatusStatus.initial,
    this.inProgressOrders = const [],
    this.readyOrders = const [],
  });

  final OrderStatusStatus status;
  final List<Order> inProgressOrders;
  final List<Order> readyOrders;
}
