import 'package:dart_mappable/dart_mappable.dart';

part 'menu_item.mapper.dart';

@MappableClass()
class MenuItem with MenuItemMappable {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.groupId,
    this.available = true,
  });

  final String id;
  final String name;

  /// The price of the menu item in cents.
  final int price;

  /// The id of the menu group this item belongs to.
  final String groupId;

  /// Whether this item is currently available for ordering.
  final bool available;
}
