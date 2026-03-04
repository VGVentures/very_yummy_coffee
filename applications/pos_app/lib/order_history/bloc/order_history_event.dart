part of 'order_history_bloc.dart';

@immutable
sealed class OrderHistoryEvent {
  const OrderHistoryEvent();
}

final class OrderHistorySubscriptionRequested extends OrderHistoryEvent {
  const OrderHistorySubscriptionRequested();
}
