import 'package:flutter/material.dart';
import 'package:menu_feature/src/widgets/menu_item_card.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Two-column grid of menu item cards. Use for kiosk-style menu items.
class MenuItemGrid extends StatelessWidget {
  const MenuItemGrid({
    required this.items,
    required this.onItemTap,
    super.key,
  });

  final List<MenuItem> items;
  final void Function(MenuItem item) onItemTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return GridView.builder(
      padding: EdgeInsets.all(spacing.xxl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: spacing.xl,
        crossAxisSpacing: spacing.xl,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onItemTap(item),
          child: MenuItemCard(
            name: item.name,
            price: item.price,
            available: item.available,
            layout: MenuItemCardLayout.grid,
          ),
        );
      },
    );
  }
}
