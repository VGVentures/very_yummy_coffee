import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/view/widgets/order_ticket_line_item.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class OrderTicket extends StatefulWidget {
  const OrderTicket({super.key});

  @override
  State<OrderTicket> createState() => _OrderTicketState();
}

class _OrderTicketState extends State<OrderTicket> {
  final _nameController = TextEditingController();

  /// Tracks the order ID the controller was last initialized for.
  String? _controllerOrderId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return BlocBuilder<OrderTicketBloc, OrderTicketState>(
      builder: (context, state) {
        final order = state.order;
        final items = order?.items ?? [];
        final subtotal = order?.total ?? 0;
        final tax = order?.tax ?? 0;
        final grandTotal = order?.grandTotal ?? 0;
        final isCharging = state.status == OrderTicketStatus.charging;
        final isIdle = state.status == OrderTicketStatus.idle;

        // Clear controller when order changes (new order or clear).
        if (order == null && _controllerOrderId != null) {
          _nameController.clear();
          _controllerOrderId = null;
        } else if (order != null && _controllerOrderId != order.id) {
          // New order — seed the controller from the order's name.
          _nameController.text = order.customerName ?? '';
          _controllerOrderId = order.id;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 12,
                right: 8,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.orderTicketCurrentOrder,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (order != null && items.isNotEmpty)
                    TextButton(
                      onPressed: isIdle
                          ? () => context.read<OrderTicketBloc>().add(
                              const OrderTicketClearRequested(),
                            )
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      child: Text(l10n.orderTicketClear),
                    ),
                ],
              ),
            ),
            // Customer name field
            if (order != null)
              Padding(
                padding: EdgeInsets.only(
                  left: spacing.lg,
                  right: spacing.lg,
                  bottom: spacing.md,
                ),
                child: TextField(
                  controller: _nameController,
                  style: typography.body,
                  maxLength: 30,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    hintText: l10n.orderTicketCustomerNameHint,
                    hintStyle: typography.body.copyWith(
                      color: colors.mutedForeground,
                    ),
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.radius.small,
                      ),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.radius.small,
                      ),
                      borderSide: BorderSide(color: colors.border),
                    ),
                  ),
                  onChanged: (value) => context.read<OrderTicketBloc>().add(
                    OrderTicketCustomerNameChanged(value),
                  ),
                ),
              ),
            const Divider(height: 1),
            // Items or empty state
            Expanded(
              child: order == null
                  ? _EmptyState(l10n: l10n)
                  : items.isEmpty
                  ? Center(child: Text(l10n.orderTicketEmpty))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) =>
                          OrderTicketLineItem(lineItem: items[index]),
                    ),
            ),
            // Footer
            if (order != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 12,
                  right: 16,
                  bottom: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PriceLine(
                      label: l10n.orderTicketSubtotal,
                      amount: subtotal,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    _PriceLine(
                      label: l10n.orderTicketTax,
                      amount: tax,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _PriceLine(
                      label: l10n.orderTicketTotal,
                      amount: grandTotal,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BaseButton(
                      label: l10n.orderTicketCharge(
                        '\$${(grandTotal / 100).toStringAsFixed(2)}',
                      ),
                      isLoading: isCharging,
                      onPressed: items.isEmpty
                          ? null
                          : () => context.read<OrderTicketBloc>().add(
                              const OrderTicketChargeRequested(),
                            ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.orderTicketEmpty,
            textAlign: TextAlign.center,
          ),
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
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.amount,
    this.style,
  });

  final String label;
  final int amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          '\$${(amount / 100).toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }
}
