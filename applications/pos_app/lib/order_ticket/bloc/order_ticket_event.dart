part of 'order_ticket_bloc.dart';

@immutable
sealed class OrderTicketEvent {
  const OrderTicketEvent();
}

final class OrderTicketSubscriptionRequested extends OrderTicketEvent {
  const OrderTicketSubscriptionRequested();
}

final class OrderTicketCreateOrderRequested extends OrderTicketEvent {
  const OrderTicketCreateOrderRequested();
}

final class OrderTicketChargeRequested extends OrderTicketEvent {
  const OrderTicketChargeRequested();
}

final class OrderTicketClearRequested extends OrderTicketEvent {
  const OrderTicketClearRequested();
}

final class OrderTicketCustomerNameChanged extends OrderTicketEvent {
  const OrderTicketCustomerNameChanged(this.name);

  final String name;
}

final class OrderTicketItemRemoved extends OrderTicketEvent {
  const OrderTicketItemRemoved(this.lineItemId);

  final String lineItemId;
}
