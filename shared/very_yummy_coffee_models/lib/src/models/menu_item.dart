import 'package:dart_mappable/dart_mappable.dart';

part 'menu_item.mapper.dart';

@MappableClass()
class MenuItem with MenuItemMappable {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;

  /// The price of the menu item in cents.
  final int price;
}
