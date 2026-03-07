import 'package:dart_mappable/dart_mappable.dart';

part 'modifier_option.mapper.dart';

/// A selectable option within a modifier group (e.g. "Oat Milk", "Grande").
@MappableClass()
class ModifierOption with ModifierOptionMappable {
  const ModifierOption({
    required this.id,
    required this.name,
    this.priceDeltaCents = 0,
  });

  final String id;
  final String name;

  /// Price adjustment in cents when this option is selected.
  final int priceDeltaCents;
}
