import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'order.mapper.dart';

@MappableEnum()
enum OrderStatus {
  pending,
  submitted,
  inProgress,
  ready,
  completed,
  cancelled,
}

/// {@template order}
/// An order.
/// {@endtemplate}

@MappableClass()
class Order with OrderMappable {
  /// {@macro order}
  const Order({
    required this.id,
    required this.items,
    required this.status,
    this.submittedAt,
  });

  final String id;
  final List<LineItem> items;
  final OrderStatus status;

  /// The time at which the order was submitted to the kitchen.
  ///
  /// Set server-side when the order transitions to [OrderStatus.submitted].
  /// Null for orders that were created before this field was introduced.
  final DateTime? submittedAt;

  int get total =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);
  int get tax => (total * 8 + 50) ~/ 100;
  int get grandTotal => total + tax;
}

/// Display helpers for [Order].
extension OrderDisplayHelpers on Order {
  /// Returns the order number for display: last 4 UUID hex chars, e.g. '#A7F2'.
  String get orderNumber => '#${id.substring(id.length - 4).toUpperCase()}';
}

@MappableClass()
class Orders with OrdersMappable {
  const Orders({
    required this.orders,
  });

  final List<Order> orders;
}
