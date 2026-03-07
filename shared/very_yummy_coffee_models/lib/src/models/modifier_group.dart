import 'package:dart_mappable/dart_mappable.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

part 'modifier_group.mapper.dart';

/// Whether a modifier group allows single or multiple selections.
@MappableEnum()
enum SelectionMode { single, multi }

/// A group of modifier options (e.g. "Size", "Milk") scoped to menu groups.
@MappableClass()
class ModifierGroup with ModifierGroupMappable {
  const ModifierGroup({
    required this.id,
    required this.name,
    required this.options,
    this.appliesToGroupIds = const [],
    this.selectionMode = SelectionMode.single,
    this.required = false,
    this.defaultOptionId,
  });

  final String id;
  final String name;

  /// Menu group IDs this modifier applies to. Empty means all groups.
  final List<String> appliesToGroupIds;

  final SelectionMode selectionMode;

  /// Whether at least one option must be selected.
  final bool required;

  /// The option ID that should be pre-selected by default.
  final String? defaultOptionId;

  final List<ModifierOption> options;
}

/// Filtering extension for lists of [ModifierGroup].
extension ModifierGroupFiltering on List<ModifierGroup> {
  /// Returns modifier groups applicable to the given [groupId].
  ///
  /// Groups with empty [ModifierGroup.appliesToGroupIds] apply to all groups.
  List<ModifierGroup> applicableTo(String groupId) => where(
    (g) => g.appliesToGroupIds.isEmpty || g.appliesToGroupIds.contains(groupId),
  ).toList();
}
