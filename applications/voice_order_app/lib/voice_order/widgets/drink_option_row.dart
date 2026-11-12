import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/widgets/highlight_on_change.dart';

/// One option of a drink: a strip of [icons] and its [label].
///
/// The label lights up briefly whenever it changes.
class DrinkOptionRow extends StatelessWidget {
  const DrinkOptionRow({
    required this.icons,
    required this.label,
    this.muted = false,
    super.key,
  });

  /// Small pictograms for the option, built with [DrinkOptionIcon].
  final List<Widget> icons;
  final String label;

  /// Dims the label, for options that do not apply ("No milk").
  final bool muted;

  static const _iconStripWidth = 68.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Row(
      children: [
        SizedBox(
          width: _iconStripWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: icons,
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: HighlightOnChange(
              value: label,
              builder: (context, strength) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.accentGold.withValues(alpha: 0.45 * strength),
                  borderRadius: BorderRadius.circular(radius.pill),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.copyWith(
                    fontWeight: strength > 0
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: muted && strength == 0
                        ? colors.navBarInactive
                        : colors.foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A pictogram in a [DrinkOptionRow], drawn strongly when [active].
class DrinkOptionIcon extends StatelessWidget {
  const DrinkOptionIcon(
    this.icon, {
    required this.active,
    this.size = 16,
    super.key,
  });

  final IconData icon;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        icon,
        key: ValueKey(active),
        size: size,
        color: active ? colors.primary : colors.border,
      ),
    );
  }
}
