part of 'pos_order_complete_bloc.dart';

enum PosOrderCompleteStatus { loading, success, failure, navigatingAway }

@MappableClass()
class PosOrderCompleteState with PosOrderCompleteStateMappable {
  const PosOrderCompleteState({
    this.status = PosOrderCompleteStatus.loading,
    this.order,
  });

  final PosOrderCompleteStatus status;
  final Order? order;
}
