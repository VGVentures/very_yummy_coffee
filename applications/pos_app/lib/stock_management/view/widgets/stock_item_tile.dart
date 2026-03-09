import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class StockItemTile extends StatelessWidget {
  const StockItemTile({
    required this.name,
    required this.price,
    required this.available,
    required this.onToggled,
    super.key,
  });

  final String name;
  final int price;
  final bool available;
  final ValueChanged<bool> onToggled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: typography.body.copyWith(
                color: available ? colors.foreground : colors.mutedForeground,
              ),
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(
            '\$${(price / 100).toStringAsFixed(2)}',
            style: typography.caption.copyWith(
              color: available ? colors.foreground : colors.mutedForeground,
            ),
          ),
          SizedBox(width: spacing.md),
          Switch(
            value: available,
            onChanged: onToggled,
            activeThumbColor: colors.success,
          ),
        ],
      ),
    );
  }
}
