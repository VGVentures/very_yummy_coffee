import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'selected_modifier.mapper.dart';

/// A modifier group selection on a line item, containing chosen options.
@MappableClass()
class SelectedModifier with SelectedModifierMappable {
  const SelectedModifier({
    required this.modifierGroupId,
    required this.modifierGroupName,
    this.options = const [],
  });

  final String modifierGroupId;
  final String modifierGroupName;
  final List<SelectedOption> options;
}
