part of 'kds_bloc.dart';

@immutable
sealed class KdsEvent {
  const KdsEvent();
}

class KdsSubscriptionRequested extends KdsEvent {
  const KdsSubscriptionRequested();
}

class KdsOrderStarted extends KdsEvent {
  const KdsOrderStarted(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is KdsOrderStarted && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

class KdsOrderMarkedReady extends KdsEvent {
  const KdsOrderMarkedReady(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is KdsOrderMarkedReady && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

class KdsOrderCompleted extends KdsEvent {
  const KdsOrderCompleted(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is KdsOrderCompleted && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

class KdsOrderCancelled extends KdsEvent {
  const KdsOrderCancelled(this.orderId);

  final String orderId;

  @override
  bool operator ==(Object other) =>
      other is KdsOrderCancelled && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}
