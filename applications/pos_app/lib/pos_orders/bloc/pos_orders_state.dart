part of 'pos_orders_bloc.dart';

enum PosOrdersStatus { loading, success, failure }

@MappableClass()
class PosOrdersState with PosOrdersStateMappable {
  const PosOrdersState({
    this.status = PosOrdersStatus.loading,
    this.activeOrders = const [],
    this.historyOrders = const [],
  });

  final PosOrdersStatus status;
  final List<Order> activeOrders;
  final List<Order> historyOrders;
}
