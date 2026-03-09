import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';
import 'package:very_yummy_coffee_ui/src/widgets/out_of_stock_badge.dart';

/// {@template unavailable_overlay}
/// Wraps a [child] widget with a dimmed overlay and an [OutOfStockBadge]
/// when [isUnavailable] is true.
///
/// When the item is available, the [child] is rendered unmodified.
/// {@endtemplate}
class UnavailableOverlay extends StatelessWidget {
  /// {@macro unavailable_overlay}
  const UnavailableOverlay({
    required this.child,
    required this.isUnavailable,
    super.key,
  });

  /// The widget to display underneath the overlay.
  final Widget child;

  /// Whether the item is unavailable (out of stock).
  final bool isUnavailable;

  @override
  Widget build(BuildContext context) {
    if (!isUnavailable) return child;

    final colors = context.colors;

    return Semantics(
      label: 'Unavailable',
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: colors.unavailableOverlay),
            ),
          ),
          const OutOfStockBadge(),
        ],
      ),
    );
  }
}
