import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/view/widgets/order_ticket.dart';

/// Order ticket feature panel.
///
/// Provides [OrderTicketBloc] scoped to this widget subtree and handles
/// navigation to the order complete screen when an order is submitted.
class OrderTicketView extends StatelessWidget {
  const OrderTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrderTicketBloc(orderRepository: context.read<OrderRepository>())
            ..add(const OrderTicketSubscriptionRequested())
            ..add(const OrderTicketCreateOrderRequested()),
      child: BlocListener<OrderTicketBloc, OrderTicketState>(
        listenWhen: (prev, curr) =>
            curr.status == OrderTicketStatus.submitted &&
            prev.status != OrderTicketStatus.submitted,
        listener: (context, state) {
          final orderId = state.submittedOrderId!;
          context.go('/order-complete/$orderId');
        },
        child: const OrderTicket(),
      ),
    );
  }
}
