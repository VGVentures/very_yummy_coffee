import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'order.mapper.dart';

@MappableEnum()
enum OrderStatus {
  pending,
  submitted,
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
  });

  final String id;
  final List<LineItem> items;
  final OrderStatus status;
  int get total =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);
  int get tax => (total * 8 + 50) ~/ 100;
  int get grandTotal => total + tax;
}

@MappableClass()
class Orders with OrdersMappable {
  const Orders({
    required this.orders,
  });

  final List<Order> orders;
}
