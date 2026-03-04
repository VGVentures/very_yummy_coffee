part of 'order_ticket_bloc.dart';

enum OrderTicketStatus { loading, idle, charging, submitted, failure }

@MappableClass()
class OrderTicketState with OrderTicketStateMappable {
  const OrderTicketState({
    this.status = OrderTicketStatus.loading,
    this.order,
    this.submittedOrderId,
  });

  final OrderTicketStatus status;
  final Order? order;
  final String? submittedOrderId;
}
