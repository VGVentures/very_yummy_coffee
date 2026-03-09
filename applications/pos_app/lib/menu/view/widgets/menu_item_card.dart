import 'package:flutter/material.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    required this.item,
    required this.onAdd,
    super.key,
  });

  final MenuItem item;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Semantics(
      label: item.available ? item.name : '${item.name}, Unavailable',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: spacing.sm + spacing.xxs,
                    top: spacing.sm + spacing.xxs,
                    right: spacing.sm + spacing.xxs,
                    bottom: spacing.xs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: typography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.foreground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      Text(
                        '\$${(item.price / 100).toStringAsFixed(2)}',
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: item.available ? onAdd : null,
                  child: ColoredBox(
                    color: item.available ? colors.primary : colors.border,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: spacing.sm + spacing.xxs,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 14,
                            color: item.available
                                ? colors.primaryForeground
                                : colors.mutedForeground,
                          ),
                          SizedBox(width: spacing.xs),
                          Text(
                            l10n.menuItemAdd,
                            style: typography.caption.copyWith(
                              color: item.available
                                  ? colors.primaryForeground
                                  : colors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!item.available)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 44,
                child: ColoredBox(
                  color: colors.unavailableOverlay,
                  child: Center(
                    child: Text(
                      l10n.menuItemUnavailable,
                      style: typography.caption.copyWith(
                        color: colors.primaryForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
