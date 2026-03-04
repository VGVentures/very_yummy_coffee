part of 'order_complete_bloc.dart';

@immutable
sealed class OrderCompleteEvent {
  const OrderCompleteEvent();
}

final class OrderCompleteSubscriptionRequested extends OrderCompleteEvent {
  const OrderCompleteSubscriptionRequested(this.orderId);

  final String orderId;
}

final class OrderCompleteNewOrderRequested extends OrderCompleteEvent {
  const OrderCompleteNewOrderRequested();
}
