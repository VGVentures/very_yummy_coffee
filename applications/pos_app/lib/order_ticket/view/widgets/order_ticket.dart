import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/view/widgets/order_ticket_line_item.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class OrderTicket extends StatelessWidget {
  const OrderTicket({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<OrderTicketBloc, OrderTicketState>(
      builder: (context, state) {
        final order = state.order;
        final items = order?.items ?? [];
        final total = order?.total ?? 0;
        final isCharging = state.status == OrderTicketStatus.charging;
        final isIdle = state.status == OrderTicketStatus.idle;

        if (order == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.orderTicketEmpty),
                const SizedBox(height: 24),
                BaseButton(
                  label: l10n.orderTicketNewOrder,
                  onPressed: () => context.read<OrderTicketBloc>().add(
                    const OrderTicketCreateOrderRequested(),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(l10n.orderTicketEmpty))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          OrderTicketLineItem(lineItem: items[index]),
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.orderTicketTotal,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '\$${(total / 100).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (items.isNotEmpty)
                        Expanded(
                          child: BaseButton(
                            label: l10n.orderTicketClear,
                            variant: BaseButtonVariant.secondary,
                            onPressed: isIdle
                                ? () => context.read<OrderTicketBloc>().add(
                                    const OrderTicketClearRequested(),
                                  )
                                : null,
                          ),
                        ),
                      if (items.isNotEmpty) const SizedBox(width: 8),
                      Expanded(
                        child: BaseButton(
                          label: l10n.orderTicketCharge(
                            '\$${(total / 100).toStringAsFixed(2)}',
                          ),
                          isLoading: isCharging,
                          onPressed: items.isEmpty
                              ? null
                              : () => context.read<OrderTicketBloc>().add(
                                  const OrderTicketChargeRequested(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
