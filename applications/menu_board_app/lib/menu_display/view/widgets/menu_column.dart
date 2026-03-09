import 'package:flutter/material.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/price_formatter.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuColumn extends StatelessWidget {
  const MenuColumn({
    required this.groupEntries,
    super.key,
  });

  /// List of (group, items) pairs. Groups with empty items are omitted
  /// by the caller.
  final List<(MenuGroup, List<MenuItem>)> groupEntries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

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
                          color: item.available
                              ? colors.foreground
                              : colors.mutedForeground,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.lg),
                    if (item.available)
                      Text(
                        formatPrice(item.price),
                        style: typography.body.copyWith(
                          color: colors.mutedForeground,
                        ),
                      )
                    else
                      Text(
                        l10n.notAvailable,
                        style: typography.caption.copyWith(
                          color: colors.statusDestructiveForeground,
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
