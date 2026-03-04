part of 'menu_bloc.dart';

enum MenuStatus { loading, success, failure }

@MappableClass()
class MenuState with MenuStateMappable {
  const MenuState({
    this.status = MenuStatus.loading,
    this.groups = const [],
    this.allItems = const [],
    this.selectedGroupId,
  });

  final MenuStatus status;
  final List<MenuGroup> groups;
  final List<MenuItem> allItems;
  final String? selectedGroupId;

  List<MenuItem> get visibleItems => selectedGroupId == null
      ? allItems
      : allItems.where((i) => i.groupId == selectedGroupId).toList();
}
