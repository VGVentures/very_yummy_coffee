import 'package:flutter/material.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_order_card.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// A single column on the KDS display (NEW, IN PROGRESS, or READY).
///
/// Renders a color-accented header with the column [label], followed by a
/// scrollable list of [orders]. Each card shows an action button labeled
/// [actionLabel] and triggers [onAction] / [onCancel] callbacks.
class KdsColumn extends StatelessWidget {
  const KdsColumn({
    required this.orders,
    required this.accentColor,
    required this.label,
    required this.actionLabel,
    required this.onAction,
    required this.onCancel,
    super.key,
  });

  final List<Order> orders;
  final Color accentColor;
  final String label;
  final String actionLabel;
  final void Function(String orderId) onAction;
  final void Function(String orderId) onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column header
          Container(
            color: accentColor.withValues(alpha: 0.12),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Text(
                  label,
                  style: typography.subtitle.copyWith(
                    color: accentColor,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Text(
                  '(${orders.length})',
                  style: typography.body.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable order cards
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return KdsOrderCard(
                  key: ValueKey(order.id),
                  order: order,
                  accentColor: accentColor,
                  actionLabel: actionLabel,
                  onAction: () => onAction(order.id),
                  onCancel: () => onCancel(order.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
