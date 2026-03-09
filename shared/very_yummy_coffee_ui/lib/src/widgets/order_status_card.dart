import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// {@template order_status_card}
/// A card displaying an order's display name and status label.
///
/// Accepts only primitive parameters to remain domain-agnostic.
/// {@endtemplate}
class OrderStatusCard extends StatelessWidget {
  /// {@macro order_status_card}
  const OrderStatusCard({
    required this.displayName,
    required this.statusLabel,
    required this.statusBackgroundColor,
    required this.statusForegroundColor,
    super.key,
  });

  /// The customer name or order number to display.
  final String displayName;

  /// The status text (e.g., "Preparing", "Ready").
  final String statusLabel;

  /// Background color for the status chip.
  final Color statusBackgroundColor;

  /// Text color for the status label.
  final Color statusForegroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.small),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: context.typography.label.copyWith(
                color: context.colors.foreground,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: context.spacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.sm,
              vertical: context.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: statusBackgroundColor,
              borderRadius: BorderRadius.circular(context.radius.pill),
            ),
            child: Text(
              statusLabel,
              style: context.typography.caption.copyWith(
                color: statusForegroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
