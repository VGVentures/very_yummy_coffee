part of 'order_complete_bloc.dart';

@MappableClass()
sealed class OrderCompleteEvent with OrderCompleteEventMappable {
  const OrderCompleteEvent();
}

@MappableClass()
class OrderCompleteSubscriptionRequested extends OrderCompleteEvent
    with OrderCompleteSubscriptionRequestedMappable {
  const OrderCompleteSubscriptionRequested({required this.orderId});

  final String orderId;
}
