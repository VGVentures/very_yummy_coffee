import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/tokens/shared_icon_size.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Data class representing a single item in the BottomTabBar.
class NavItemData {
  /// Creates a new NavItemData instance.
  ///
  /// [iconData] is the icon to display for this navigation item.
  ///
  /// [label] is the text label for this navigation item.
  const NavItemData({
    required this.iconData,
    required this.label,
  });

  /// The icon to display for this navigation item.
  final IconData iconData;

  /// The text label for this navigation item.
  final String label;
}

/// A reusable bottom navigation bar component following the design system.
///
/// This component renders a styled [BottomNavigationBar] and delegates state
/// management (selected index and tap handling) to its parent.
///
/// It applies design system colors, typography, spacing, and radius.
///
/// Example usage:
///
/// ```dart
/// int _selectedIndex = 0;
///
/// BottomTabBar(
///   currentIndex: _selectedIndex,
///   onTap: (index) => setState(() => _selectedIndex = index),
///   items: const [
///     NavItemData(iconData: Icons.home, label: 'Home'),
///     NavItemData(iconData: Icons.settings, label: 'Settings'),
///   ],
/// );
/// ```
class BottomTabBar extends StatelessWidget {
  /// {@macro bottom_tab_bar}
  const BottomTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  /// The list of navigation items to display.
  final List<NavItemData> items;

  /// The index of the currently selected item.
  final int currentIndex;

  /// The callback that is called when a navigation item is tapped.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      color: SharedColors.navBarBackground,
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: SharedColors.navBarBackground,
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
            return states.contains(WidgetState.selected)
                ? SharedTypography.navLabelActive
                : SharedTypography.navLabel;
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? SharedColors.accentGold
                  : SharedColors.navBarInactive,
              size: selected
                  ? SharedIconSize.large + 4.0
                  : SharedIconSize.large,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => onTap?.call(index),
          height: 88,
          elevation: 0,
          destinations: List.generate(items.length, (index) {
            final item = items[index];
            return NavigationDestination(
              icon: Icon(item.iconData),
              label: item.label,
            );
          }),
        ),
      ),
    );
  }
}
