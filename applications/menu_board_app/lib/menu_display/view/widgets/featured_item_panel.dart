import 'package:flutter/material.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/price_formatter.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class FeaturedItemPanel extends StatelessWidget {
  const FeaturedItemPanel({
    required this.group,
    required this.item,
    super.key,
  });

  final MenuGroup group;
  final MenuItem? item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      color: colors.card,
      padding: EdgeInsets.all(spacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.imagePlaceholder,
              image: group.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(group.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          SizedBox(height: spacing.xxl),
          Text(
            group.name,
            style: typography.headline.copyWith(color: colors.foreground),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.md),
          if (item case final item?) ...[
            Text(
              item.name,
              style: typography.subtitle.copyWith(
                color: item.available
                    ? colors.foreground
                    : colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            if (item.available)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(radius.pill),
                ),
                child: Text(
                  formatPrice(item.price),
                  style: typography.subtitle.copyWith(
                    color: colors.primaryForeground,
                  ),
                ),
              )
            else
              Text(
                context.l10n.notAvailable,
                style: typography.body.copyWith(
                  color: colors.statusDestructiveForeground,
                ),
                textAlign: TextAlign.center,
              ),
          ] else
            Text(
              context.l10n.notAvailable,
              style: typography.body.copyWith(color: colors.mutedForeground),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
