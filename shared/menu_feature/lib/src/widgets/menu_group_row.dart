import 'package:flutter/material.dart';
import 'package:menu_feature/src/widgets/menu_group_card.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Horizontal row of menu group cards. Use for kiosk-style menu groups.
class MenuGroupRow extends StatelessWidget {
  const MenuGroupRow({
    required this.groups,
    required this.onGroupTap,
    super.key,
  });

  final List<MenuGroup> groups;
  final void Function(MenuGroup group) onGroupTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.xxl),
      child: Row(
        children: groups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : spacing.md,
                right: index == groups.length - 1 ? 0 : spacing.md,
              ),
              child: GestureDetector(
                onTap: () => onGroupTap(group),
                child: MenuGroupCard(
                  name: group.name,
                  description: group.description,
                  color: group.color,
                  layout: MenuGroupCardLayout.row,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
