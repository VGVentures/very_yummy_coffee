import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// {@template out_of_stock_badge}
/// A small badge indicating an item is out of stock.
///
/// Renders a destructive-colored chip with a configurable [label]
/// (defaults to "Unavailable"). Uses design tokens from the theme.
/// {@endtemplate}
class OutOfStockBadge extends StatelessWidget {
  /// {@macro out_of_stock_badge}
  const OutOfStockBadge({
    this.label = 'Unavailable',
    super.key,
  });

  /// The text to display on the badge.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.statusDestructiveBackground,
          borderRadius: BorderRadius.circular(radius.small),
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: colors.statusDestructiveForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
