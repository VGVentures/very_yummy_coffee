import 'package:flutter/material.dart';
import 'package:menu_feature/src/widgets/menu_group_card.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Vertical list of menu group cards. Use for mobile-style menu groups.
class MenuGroupList extends StatelessWidget {
  const MenuGroupList({
    required this.groups,
    required this.onGroupTap,
    super.key,
  });

  final List<MenuGroup> groups;
  final void Function(MenuGroup group) onGroupTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(context.spacing.xl),
      itemCount: groups.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.lg),
      itemBuilder: (context, index) {
        final group = groups[index];
        return GestureDetector(
          onTap: () => onGroupTap(group),
          child: MenuGroupCard(
            name: group.name,
            description: group.description,
            color: group.color,
          ),
        );
      },
    );
  }
}
