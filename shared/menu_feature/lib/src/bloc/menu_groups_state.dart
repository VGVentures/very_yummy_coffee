part of 'menu_groups_bloc.dart';

@MappableEnum()
enum MenuGroupsStatus { initial, loading, success, failure }

@MappableClass()
class MenuGroupsState with MenuGroupsStateMappable {
  const MenuGroupsState({
    this.status = MenuGroupsStatus.initial,
    this.menuGroups = const [],
  });

  final MenuGroupsStatus status;
  final List<MenuGroup> menuGroups;
}
