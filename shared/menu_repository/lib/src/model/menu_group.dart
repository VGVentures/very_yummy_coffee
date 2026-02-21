import 'package:dart_mappable/dart_mappable.dart';

part 'menu_group.mapper.dart';

@MappableClass()
class MenuGroup with MenuGroupMappable {
  const MenuGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final int color; // Color value (0xAARRGGBB)
  final String? imageUrl;
}
