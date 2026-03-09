import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/menu_category_tabs.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/menu_item_grid.dart';

/// Menu feature panel.
///
/// Renders the category tabs and item grid.
/// Expects a `MenuBloc` to be provided by an ancestor widget.
class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MenuCategoryTabs(),
        Expanded(child: MenuItemGrid()),
      ],
    );
  }
}
