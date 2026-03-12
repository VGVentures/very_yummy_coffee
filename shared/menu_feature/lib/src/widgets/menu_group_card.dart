import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Internal card for a menu group used by list and row widgets.
/// [layout] controls list-style (horizontal bar) vs row-style (vertical card).
class MenuGroupCard extends StatelessWidget {
  const MenuGroupCard({
    required this.name,
    required this.description,
    required this.color,
    super.key,
    this.layout = MenuGroupCardLayout.list,
  });

  final String name;
  final String description;
  final int color;
  final MenuGroupCardLayout layout;

  @override
  Widget build(BuildContext context) {
    return layout == MenuGroupCardLayout.list
        ? _buildListLayout(context)
        : _buildRowLayout(context);
  }

  Widget _buildListLayout(BuildContext context) {
    final groupColor = Color(color);
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: context.colors.border),
      ),
      padding: EdgeInsets.all(context.spacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: context.typography.subtitle.copyWith(
                    fontSize: 20,
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Text(
                  description,
                  style: context.typography.muted,
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: groupColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(context.radius.medium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    final groupColor = Color(color);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.card),
        border: Border.all(color: context.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    groupColor.withValues(alpha: 0.3),
                    groupColor.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_cafe_outlined,
                  size: 64,
                  color: groupColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.typography.subtitle.copyWith(
                    color: groupColor,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Text(
                  description,
                  style: context.typography.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum MenuGroupCardLayout { list, row }
