import 'package:flutter/material.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_elapsed_widget.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// A card representing a single order on the KDS display.
///
/// Renders the order number, elapsed time, line items, and action buttons.
/// The primary action button color matches [accentColor] (the column accent).
class KdsOrderCard extends StatelessWidget {
  const KdsOrderCard({
    required this.order,
    required this.accentColor,
    required this.actionLabel,
    required this.onAction,
    required this.onCancel,
    super.key,
  });

  final Order order;
  final Color accentColor;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Card(
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.card),
        side: BorderSide(color: colors.border),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: order number + elapsed/timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: typography.subtitle.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                DefaultTextStyle(
                  style: typography.caption.copyWith(
                    color: colors.mutedForeground,
                  ),
                  child: KdsElapsedWidget(
                    submittedAt: order.submittedAt,
                    isLiveTimer: order.status == OrderStatus.inProgress,
                  ),
                ),
              ],
            ),
            if (order.customerName case final name? when name.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: Text(
                  name,
                  style: typography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                ),
              ),
            SizedBox(height: spacing.sm),
            // Line items
            ...order.items.map(
              (item) {
                final modifierLabels = item.modifierOptionNames;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.xxs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity}× ${item.name}',
                        style: typography.body,
                      ),
                      if (modifierLabels.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: spacing.xxs),
                          child: ModifierSummaryChips(
                            labels: modifierLabels,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: spacing.md),
            // Action row: Cancel (left, muted) + primary action (right)
            Row(
              children: [
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.mutedForeground,
                  ),
                  child: Text(l10n.actionCancel),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: colors.primaryForeground,
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
