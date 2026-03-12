import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// {@template status_badge}
/// A pill-shaped badge displaying a status label with configurable colors.
///
/// Accepts only primitive parameters to remain domain-agnostic.
/// Styling matches the status chip in OrderStatusCard for consistency
/// across POS and menu board. Apps should pass non-empty [label] for
/// accessibility.
/// {@endtemplate}
class StatusBadge extends StatelessWidget {
  /// {@macro status_badge}
  const StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
  });

  /// The text to display (e.g. "Preparing", "Ready"). Empty string is allowed.
  final String label;

  /// Background color for the pill.
  final Color backgroundColor;

  /// Text color for the label.
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radius = context.radius;
    final typography = context.typography;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius.pill),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(color: foregroundColor),
      ),
    );
  }
}
