import 'package:flutter/material.dart';
import 'package:menu_feature/src/widgets/menu_item_card.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Vertical list of menu item cards. Use for mobile-style menu items.
class MenuItemList extends StatelessWidget {
  const MenuItemList({
    required this.items,
    required this.onItemTap,
    super.key,
  });

  final List<MenuItem> items;
  final void Function(MenuItem item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl).copyWith(
        top: context.spacing.xl,
        bottom: context.spacing.huge,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.lg),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onItemTap(item),
          child: MenuItemCard(
            name: item.name,
            price: item.price,
            available: item.available,
          ),
        );
      },
    );
  }
}
