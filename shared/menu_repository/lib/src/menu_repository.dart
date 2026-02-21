import 'package:menu_repository/menu_repository.dart';

/// {@template menu_repository}
/// A repository managing the menu domain.
/// {@endtemplate}
class MenuRepository {
  /// {@macro menu_repository}
  const MenuRepository();

  Stream<List<MenuGroup>> getMenuGroups() => Stream.value([
    const MenuGroup(
      id: '1',
      name: 'Main',
      description: 'Sandwiches, wraps & more',
      color: 0xFFF0EFE8,
    ),
    const MenuGroup(
      id: '2',
      name: 'Drinks',
      description: 'Coffee, tea & beverages',
      color: 0xFFE8DDD6,
    ),
    const MenuGroup(
      id: '3',
      name: 'Desserts',
      description: 'Pastries, cakes & sweets',
      color: 0xFFF5E6C8,
    ),
  ]);

  Stream<List<MenuItem>> getMenuItems(String groupId) => Stream.value([
    const MenuItem(id: '1', name: 'Item 1', price: 100),
    const MenuItem(id: '2', name: 'Item 2', price: 200),
    const MenuItem(id: '3', name: 'Item 3', price: 300),
  ]);
}
