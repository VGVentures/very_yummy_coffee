part of 'order_status_bloc.dart';

@immutable
sealed class OrderStatusEvent {
  const OrderStatusEvent();
}

class OrderStatusSubscriptionRequested extends OrderStatusEvent {
  const OrderStatusSubscriptionRequested();
}
