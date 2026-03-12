import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/menu/menu.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';
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
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return BlocSelector<MenuBloc, MenuState, Set<String>>(
      selector: (menuState) => {
        for (final item in menuState.allItems)
          if (!item.available) item.id,
      },
      builder: (context, unavailableMenuItemIds) {
        return BlocBuilder<OrderTicketBloc, OrderTicketState>(
          builder: (context, state) {
            final order = state.order;
            final items = order?.items ?? [];
            final subtotal = order?.total ?? 0;
            final tax = order?.tax ?? 0;
            final grandTotal = order?.grandTotal ?? 0;
            final isCharging = state.status == OrderTicketStatus.charging;
            final isIdle = state.status == OrderTicketStatus.idle;
            final hasUnavailableItems = items.any(
              (item) =>
                  item.menuItemId != null &&
                  unavailableMenuItemIds.contains(item.menuItemId),
            );

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
                  padding: EdgeInsets.only(
                    left: spacing.lg,
                    top: spacing.md,
                    right: spacing.sm,
                    bottom: spacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.orderTicketCurrentOrder,
                          style: typography.subtitle.copyWith(
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
                            foregroundColor: colors.destructive,
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
                          padding: EdgeInsets.symmetric(
                            vertical: spacing.sm,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: spacing.lg,
                            endIndent: spacing.lg,
                          ),
                          itemBuilder: (context, index) {
                            final lineItem = items[index];
                            final isUnavailable =
                                lineItem.menuItemId != null &&
                                unavailableMenuItemIds.contains(
                                  lineItem.menuItemId,
                                );
                            return OrderLineItemRow(
                              itemName: lineItem.name,
                              quantity: lineItem.quantity,
                              modifierLabels: lineItem.modifierOptionNames,
                              totalCents:
                                  lineItem.unitPriceWithModifiers *
                                  lineItem.quantity,
                              outOfStockLabel: isUnavailable
                                  ? context.l10n.cartItemUnavailable
                                  : null,
                              onRemove: () =>
                                  context.read<OrderTicketBloc>().add(
                                    OrderTicketItemRemoved(lineItem.id),
                                  ),
                            );
                          },
                        ),
                ),
                // Footer
                if (order != null) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.only(
                      left: spacing.lg,
                      top: spacing.md,
                      right: spacing.lg,
                      bottom: spacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PriceLine(
                          label: l10n.orderTicketSubtotal,
                          amount: subtotal,
                          style: typography.body,
                        ),
                        SizedBox(height: spacing.xs),
                        _PriceLine(
                          label: l10n.orderTicketTax,
                          amount: tax,
                          style: typography.body.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: spacing.sm,
                          ),
                          child: const Divider(height: 1),
                        ),
                        _PriceLine(
                          label: l10n.orderTicketTotal,
                          amount: grandTotal,
                          style: typography.subtitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: spacing.md),
                        if (hasUnavailableItems)
                          Padding(
                            padding: EdgeInsets.only(bottom: spacing.sm),
                            child: Text(
                              l10n.cartRemoveUnavailableToCheckout,
                              textAlign: TextAlign.center,
                              style: typography.caption.copyWith(
                                color: colors.destructive,
                              ),
                            ),
                          ),
                        BaseButton(
                          label: l10n.orderTicketCharge(
                            '\$${(grandTotal / 100).toStringAsFixed(2)}',
                          ),
                          isLoading: isCharging,
                          onPressed: items.isEmpty || hasUnavailableItems
                              ? null
                              : () => context.read<OrderTicketBloc>().add(
                                  const OrderTicketChargeRequested(),
                                ),
                        ),
                        SizedBox(height: spacing.md),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
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
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.orderTicketEmpty,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xxl),
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
