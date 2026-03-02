part of 'order_complete_bloc.dart';

@MappableEnum()
enum OrderCompleteStatus { loading, success, failure }

@MappableClass()
class OrderCompleteState with OrderCompleteStateMappable {
  const OrderCompleteState({
    this.status = OrderCompleteStatus.loading,
    this.order,
  });

  final OrderCompleteStatus status;
  final Order? order;
}
