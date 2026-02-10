import 'package:collection/collection.dart';
import 'package:order_repository/order_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

/// {@template order_repository}
/// A repository managing the ordering domain
/// {@endtemplate}
class OrderRepository {
  /// {@macro order_repository}
  OrderRepository({
    this.currentOrderId,
  });

  String? currentOrderId;
  static const Uuid _uuid = Uuid();

  final BehaviorSubject<Orders> _currentOrdersSubject = BehaviorSubject.seeded(
    const Orders(orders: []),
  );

  Stream<Orders> get ordersStream => _currentOrdersSubject.stream;
  Stream<Order?> get currentOrderStream => _currentOrdersSubject.stream.map(
    (orders) =>
        orders.orders.firstWhereOrNull((order) => order.id == currentOrderId),
  );
  Stream<Order?> orderStream(String orderId) =>
      _currentOrdersSubject.stream.map(
        (orders) =>
            orders.orders.firstWhereOrNull((order) => order.id == orderId),
      );

  List<Order> get _orders => _currentOrdersSubject.value.orders;
  Order? get _currentOrder =>
      _orders.firstWhereOrNull((order) => order.id == currentOrderId);

  set _currentOrder(Order order) {
    if (currentOrderId == order.id) {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index >= 0) {
        _currentOrdersSubject.add(
          _currentOrdersSubject.value.copyWith.orders.replace(index, order),
        );
      }
    } else {
      _currentOrdersSubject.add(
        _currentOrdersSubject.value.copyWith.orders.add(order),
      );
      currentOrderId = order.id;
    }
  }

  void addItemToCurrentOrder({
    required String itemName,
    required int itemPrice,
  }) {
    if (_currentOrder != null) {
      final id = _uuid.v4();
      final item = LineItem(id: id, name: itemName, price: itemPrice);
      _currentOrder = _currentOrder!.copyWith.items.add(item);
    }
  }

  void removeItemFromCurrentOrder(String lineItemId) {
    final order = _currentOrder;
    if (order == null) return;
    _currentOrder = order.copyWith.items.removeAt(
      order.items.indexWhere((i) => i.id == lineItemId),
    );
  }

  void completeCurrentOrder() {
    final order = _currentOrder;
    if (order == null) return;
    _currentOrder = order.copyWith(status: OrderStatus.completed);
    currentOrderId = null;
  }

  Future<void> createOrder() async {
    _currentOrder = Order(
      id: _uuid.v4(),
      items: [],
      status: OrderStatus.pending,
    );
  }
}
