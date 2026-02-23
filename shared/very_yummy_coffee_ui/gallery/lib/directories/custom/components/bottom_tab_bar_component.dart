import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component showcasing BottomTabBar.
final bottomTabBarComponent = WidgetbookComponent(
  name: 'BottomTabBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Scaffold(
        bottomNavigationBar: BottomTabBar(
          currentIndex: context.knobs.int.slider(
            label: 'Selected item',
            initialValue: 2,
            max: 4,
          ),
          onTap: (_) {},
          items: const [
            NavItemData(iconData: Icons.history_rounded, label: 'Recent'),
            NavItemData(iconData: Icons.star_rounded, label: 'Rewards'),
            NavItemData(iconData: Icons.restaurant_menu_rounded, label: 'Menu'),
            NavItemData(iconData: Icons.store_rounded, label: 'Store'),
            NavItemData(iconData: Icons.person_rounded, label: 'More'),
          ],
        ),
      ),
    ),
  ],
);
