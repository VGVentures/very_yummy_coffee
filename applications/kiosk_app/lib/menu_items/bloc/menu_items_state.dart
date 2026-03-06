part of 'menu_items_bloc.dart';

@MappableEnum()
enum MenuItemsStatus { initial, loading, success, failure }

@MappableClass()
class MenuItemsState with MenuItemsStateMappable {
  const MenuItemsState({
    this.status = MenuItemsStatus.initial,
    this.menuItems = const [],
    this.groupName = '',
  });

  final MenuItemsStatus status;
  final List<MenuItem> menuItems;
  final String groupName;
}
