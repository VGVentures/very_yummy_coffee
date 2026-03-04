part of 'order_complete_bloc.dart';

enum OrderCompleteStatus { loading, success, failure, navigatingAway }

@MappableClass()
class OrderCompleteState with OrderCompleteStateMappable {
  const OrderCompleteState({
    this.status = OrderCompleteStatus.loading,
    this.order,
  });

  final OrderCompleteStatus status;
  final Order? order;
}
