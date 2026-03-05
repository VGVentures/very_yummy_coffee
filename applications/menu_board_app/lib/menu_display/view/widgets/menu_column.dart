import 'package:flutter/material.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/price_formatter.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuColumn extends StatelessWidget {
  const MenuColumn({
    required this.groupEntries,
    super.key,
  });

  /// List of (group, availableItems) pairs. Groups with empty items are omitted
  /// by the caller.
  final List<(MenuGroup, List<MenuItem>)> groupEntries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (group, items) in groupEntries) ...[
            Padding(
              padding: EdgeInsets.only(
                left: spacing.xxl,
                right: spacing.xxl,
                bottom: spacing.md,
              ),
              child: Text(
                group.name,
                style: typography.label.copyWith(color: colors.foreground),
              ),
            ),
            for (final item in items)
              Padding(
                padding: EdgeInsets.only(
                  left: spacing.xxl,
                  right: spacing.xxl,
                  bottom: spacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: typography.body.copyWith(
                          color: colors.foreground,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.lg),
                    Text(
                      formatPrice(item.price),
                      style: typography.body.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: spacing.xl),
          ],
        ],
      ),
    );
  }
}
