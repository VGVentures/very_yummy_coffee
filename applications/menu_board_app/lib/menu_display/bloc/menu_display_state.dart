part of 'menu_display_bloc.dart';

enum MenuDisplayStatus { initial, loading, success, failure }

@MappableClass()
final class MenuDisplayState with MenuDisplayStateMappable {
  const MenuDisplayState({
    this.status = MenuDisplayStatus.initial,
    this.groups = const [],
    this.items = const [],
  });

  final MenuDisplayStatus status;
  final List<MenuGroup> groups;
  final List<MenuItem> items;

  MenuItem? get featuredLeft => groups.isNotEmpty
      ? items
            .where((i) => i.groupId == groups.first.id && i.available)
            .firstOrNull
      : null;

  MenuItem? get featuredRight => groups.isNotEmpty
      ? items
            .where((i) => i.groupId == groups.last.id && i.available)
            .firstOrNull
      : null;

  int get _midpoint => (groups.length / 2).ceil();

  List<(MenuGroup, List<MenuItem>)> get leftGroupEntries =>
      _groupEntriesFor(groups.sublist(0, _midpoint));

  List<(MenuGroup, List<MenuItem>)> get rightGroupEntries =>
      _groupEntriesFor(groups.sublist(_midpoint));

  List<(MenuGroup, List<MenuItem>)> _groupEntriesFor(List<MenuGroup> gs) => gs
      .map(
        (g) => (
          g,
          items.where((i) => i.groupId == g.id && i.available).toList(),
        ),
      )
      .where((entry) => entry.$2.isNotEmpty)
      .toList();
}
