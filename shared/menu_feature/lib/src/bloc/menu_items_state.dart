part of 'menu_items_bloc.dart';

@MappableEnum()
enum MenuItemsStatus { initial, loading, success, failure }

@MappableClass()
class MenuItemsState with MenuItemsStateMappable {
  const MenuItemsState({
    this.status = MenuItemsStatus.initial,
    this.group,
    this.menuItems = const [],
  });

  final MenuItemsStatus status;
  final MenuGroup? group;
  final List<MenuItem> menuItems;
}
