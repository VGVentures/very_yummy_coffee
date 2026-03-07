import 'package:dart_mappable/dart_mappable.dart';

part 'selected_option.mapper.dart';

/// A specific option chosen within a modifier group on a line item.
@MappableClass()
class SelectedOption with SelectedOptionMappable {
  const SelectedOption({
    required this.id,
    required this.name,
    this.priceDeltaCents = 0,
  });

  final String id;
  final String name;

  /// Price adjustment in cents for this selected option.
  final int priceDeltaCents;
}
