import 'package:flutter/material.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_elapsed_widget.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// A card representing a single order on the KDS display.
///
/// Uses [OrderCard] with line summaries; elapsed and actions are passed
/// as [OrderCard.elapsedWidget] and [OrderCard.trailing].
/// The primary action button color matches [accentColor] (the column accent).
class KdsOrderCard extends StatelessWidget {
  const KdsOrderCard({
    required this.order,
    required this.accentColor,
    this.actionLabel,
    this.onAction,
    this.onCancel,
    super.key,
  });

  final Order order;
  final Color accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;

    final lineSummaries = order.items
        .map((i) => '${i.quantity}× ${i.name}')
        .toList();
    final totalDisplayText = '\$${(order.total / 100).toStringAsFixed(2)}';

    Widget? elapsedWidget;
    if (onAction != null) {
      elapsedWidget = KdsElapsedWidget(
        submittedAt: order.submittedAt,
        isLiveTimer: order.status == OrderStatus.inProgress,
      );
    }

    Widget? trailing;
    if (onAction != null && actionLabel != null) {
      trailing = Row(
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
            child: Text(actionLabel!),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: OrderCard(
        orderNumber: order.orderNumber,
        orderNumberColor: accentColor,
        customerName: order.customerName,
        lineSummaries: lineSummaries,
        totalDisplayText: totalDisplayText,
        elapsedWidget: elapsedWidget,
        trailing: trailing,
      ),
    );
  }
}
