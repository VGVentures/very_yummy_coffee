import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';

class OrderTicketLineItem extends StatelessWidget {
  const OrderTicketLineItem({required this.lineItem, super.key});

  final LineItem lineItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            lineItem.name,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '\$${(lineItem.price / 100).toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: () => context.read<OrderTicketBloc>().add(
            OrderTicketItemRemoved(lineItem.id),
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
