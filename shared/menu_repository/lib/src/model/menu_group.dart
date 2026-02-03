import 'package:dart_mappable/dart_mappable.dart';

part 'menu_group.mapper.dart';

@MappableClass()
class MenuGroup with MenuGroupMappable {
  const MenuGroup({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
