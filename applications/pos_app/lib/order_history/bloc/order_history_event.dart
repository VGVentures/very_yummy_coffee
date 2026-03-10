part of 'order_history_bloc.dart';

@immutable
sealed class OrderHistoryEvent {
  const OrderHistoryEvent();
}

final class OrderHistorySubscriptionRequested extends OrderHistoryEvent {
  const OrderHistorySubscriptionRequested();
}

final class OrderHistoryOrderStarted extends OrderHistoryEvent {
  const OrderHistoryOrderStarted(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is OrderHistoryOrderStarted && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

final class OrderHistoryOrderMarkedReady extends OrderHistoryEvent {
  const OrderHistoryOrderMarkedReady(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is OrderHistoryOrderMarkedReady && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

final class OrderHistoryOrderCompleted extends OrderHistoryEvent {
  const OrderHistoryOrderCompleted(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is OrderHistoryOrderCompleted && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

final class OrderHistoryOrderCancelled extends OrderHistoryEvent {
  const OrderHistoryOrderCancelled(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is OrderHistoryOrderCancelled && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}
