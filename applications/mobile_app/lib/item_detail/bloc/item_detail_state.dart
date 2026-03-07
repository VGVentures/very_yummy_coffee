part of 'item_detail_bloc.dart';

@MappableEnum()
enum ItemDetailStatus { loading, idle, adding, added, failure }

@MappableClass()
class ItemDetailState with ItemDetailStateMappable {
  const ItemDetailState({
    this.item,
    this.applicableModifierGroups = const [],
    this.selectedModifiers = const {},
    this.quantity = 1,
    this.status = ItemDetailStatus.loading,
  });

  final MenuItem? item;
  final List<ModifierGroup> applicableModifierGroups;

  /// Maps modifier group ID to list of selected option IDs.
  final Map<String, List<String>> selectedModifiers;

  final int quantity;
  final ItemDetailStatus status;

  /// Total price including base price and modifier deltas, times quantity.
  int get totalPrice {
    final basePrice = item?.price ?? 0;
    var modifierDelta = 0;
    for (final group in applicableModifierGroups) {
      final selectedIds = selectedModifiers[group.id] ?? [];
      for (final option in group.options) {
        if (selectedIds.contains(option.id)) {
          modifierDelta += option.priceDeltaCents;
        }
      }
    }
    return (basePrice + modifierDelta) * quantity;
  }

  /// Whether all required modifier groups have at least one selection.
  bool get canAddToCart {
    for (final group in applicableModifierGroups) {
      if (group.required) {
        final selectedIds = selectedModifiers[group.id] ?? [];
        if (selectedIds.isEmpty) return false;
      }
    }
    return true;
  }
}
