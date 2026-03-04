part of 'order_history_bloc.dart';

enum OrderHistoryStatus { loading, success, failure }

@MappableClass()
class OrderHistoryState with OrderHistoryStateMappable {
  const OrderHistoryState({
    this.status = OrderHistoryStatus.loading,
    this.activeOrders = const [],
    this.historyOrders = const [],
  });

  final OrderHistoryStatus status;
  final List<Order> activeOrders;
  final List<Order> historyOrders;
}
