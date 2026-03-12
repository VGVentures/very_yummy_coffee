import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Internal card for a menu item used by list and grid widgets.
/// [layout] controls list-style (horizontal row) vs grid-style (vertical card).
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    required this.name,
    required this.price,
    required this.available,
    super.key,
    this.layout = MenuItemCardLayout.list,
  });

  final String name;
  final int price;
  final bool available;
  final MenuItemCardLayout layout;

  static String _formatPrice(int cents) =>
      '\$${(cents / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return layout == MenuItemCardLayout.list
        ? _buildListLayout(context)
        : _buildGridLayout(context);
  }

  Widget _buildListLayout(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radius.large),
      child: UnavailableOverlay(
        isUnavailable: !available,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(context.radius.large),
            border: Border.all(color: context.colors.border),
          ),
          padding: EdgeInsets.all(context.spacing.xl),
          child: Row(
            children: [
              Container(
                width: context.iconSize.imageThumbnail,
                height: context.iconSize.imageThumbnail,
                decoration: BoxDecoration(
                  color: context.colors.imagePlaceholder,
                  borderRadius: BorderRadius.circular(context.radius.medium),
                ),
              ),
              SizedBox(width: context.spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: context.typography.subtitle.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: context.spacing.xs),
                    Text(
                      _formatPrice(price),
                      style: context.typography.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(context.radius.card),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: UnavailableOverlay(
        isUnavailable: !available,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.imagePlaceholder,
                      colors.imagePlaceholder.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.local_cafe_outlined,
                    size: 48,
                    color: colors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.typography.subtitle.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  Text(
                    _formatPrice(price),
                    style: context.typography.body.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MenuItemCardLayout { list, grid }
