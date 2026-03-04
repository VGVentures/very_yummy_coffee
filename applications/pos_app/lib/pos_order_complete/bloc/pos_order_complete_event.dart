part of 'pos_order_complete_bloc.dart';

@immutable
sealed class PosOrderCompleteEvent {
  const PosOrderCompleteEvent();
}

final class PosOrderCompleteSubscriptionRequested
    extends PosOrderCompleteEvent {
  const PosOrderCompleteSubscriptionRequested(this.orderId);

  final String orderId;
}

final class PosOrderCompleteNewOrderRequested extends PosOrderCompleteEvent {
  const PosOrderCompleteNewOrderRequested();
}
