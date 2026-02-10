import 'package:dart_mappable/dart_mappable.dart';

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
  });

  final String id;
  final String name;
  final int price;
}
