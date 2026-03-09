import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'line_item.mapper.dart';

/// {@template line_item}
/// A line item in an order.
/// {@endtemplate}
@MappableClass()
class LineItem with LineItemMappable {
  /// {@macro line_item}
  const LineItem({
    required this.id,
    required this.name,
    required this.price,
    this.menuItemId,
    this.modifiers = const [],
    this.quantity = 1,
  });

  final String id;
  final String name;
  final int price;
  final String? menuItemId;
  final List<SelectedModifier> modifiers;
  final int quantity;

  /// Sum of all selected modifier option price deltas.
  int get modifierPriceDelta => modifiers.fold(
    0,
    (sum, mod) =>
        sum + mod.options.fold(0, (s, opt) => s + opt.priceDeltaCents),
  );

  /// Base price plus modifier deltas.
  int get unitPriceWithModifiers => price + modifierPriceDelta;

  /// Flat list of selected modifier option names (e.g. ["Medium", "Oat Milk"]).
  List<String> get modifierOptionNames =>
      modifiers.expand((m) => m.options).map((o) => o.name).toList();
}
