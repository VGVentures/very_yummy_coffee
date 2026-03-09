import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class OrderTicketLineItem extends StatelessWidget {
  const OrderTicketLineItem({
    required this.lineItem,
    this.isUnavailable = false,
    super.key,
  });

  final LineItem lineItem;
  final bool isUnavailable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final total = lineItem.unitPriceWithModifiers * lineItem.quantity;
    final modifierLabels = lineItem.modifierOptionNames;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.sm - spacing.xxs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lineItem.name,
                  style: typography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isUnavailable ? colors.mutedForeground : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (modifierLabels.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xxs),
                    child: ModifierSummaryChips(labels: modifierLabels),
                  ),
                if (isUnavailable)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xs),
                    child: OutOfStockBadge(
                      label: context.l10n.cartItemUnavailable,
                    ),
                  ),
                if (lineItem.quantity > 1)
                  Text(
                    'Qty: ${lineItem.quantity}',
                    style: typography.caption.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(
            '\$${(total / 100).toStringAsFixed(2)}',
            style: typography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: spacing.xs),
          GestureDetector(
            onTap: () => context.read<OrderTicketBloc>().add(
              OrderTicketItemRemoved(lineItem.id),
            ),
            child: Icon(
              Icons.close,
              size: 18,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
