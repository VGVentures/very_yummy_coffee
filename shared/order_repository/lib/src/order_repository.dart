import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:collection/collection.dart';
import 'package:order_repository/order_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

/// {@template order_repository}
/// A repository managing the ordering domain.
///
/// All mutations are sent to the server as WebSocket actions, which broadcasts
/// the resulting state change to all subscribed clients. The [ordersStream]
/// subscribes to the 'orders' topic on first access and stays active for the
/// session, so all derived streams ([currentOrderStream], [orderStream]) stay
/// in sync with the server.
/// {@endtemplate}
class OrderRepository {
  /// {@macro order_repository}
  OrderRepository({
    required WsRpcClient wsRpcClient,
    String? currentOrderId,
  }) : _wsRpcClient = wsRpcClient,
       _currentOrderId = currentOrderId;

  final WsRpcClient _wsRpcClient;

  String? _currentOrderId;

  String? get currentOrderId => _currentOrderId;
  static const Uuid _uuid = Uuid();

  BehaviorSubject<Orders>? _ordersSubject;
  StreamSubscription<Map<String, dynamic>>? _ordersWsSub;

  /// A live stream of all orders, synced from the server.
  ///
  /// Subscribes to the 'orders' WebSocket topic on first access.
  Stream<Orders> get ordersStream {
    _initOrdersIfNeeded();
    return _ordersSubject!.stream;
  }

  /// A live stream of the current order (tracked by [currentOrderId]).
  Stream<Order?> get currentOrderStream => ordersStream.map(
    (orders) =>
        orders.orders.firstWhereOrNull((order) => order.id == currentOrderId),
  );

  /// A live stream of a specific order by [orderId].
  Stream<Order?> orderStream(String orderId) => ordersStream.map(
    (orders) => orders.orders.firstWhereOrNull((order) => order.id == orderId),
  );

  /// Creates a new order on the server.
  ///
  /// Sets [currentOrderId] immediately so derived streams reflect the new
  /// order once the server broadcasts the update.
  Future<void> createOrder() async {
    final id = _uuid.v4();
    _currentOrderId = id;
    _wsRpcClient.sendAction('createOrder', {'id': id});
  }

  /// Adds an item to the current order on the server.
  void addItemToCurrentOrder({
    required String itemName,
    required int itemPrice,
    required String options,
    required int quantity,
  }) {
    if (currentOrderId == null) return;
    _wsRpcClient.sendAction('addItemToOrder', {
      'orderId': currentOrderId,
      'lineItemId': _uuid.v4(),
      'itemName': itemName,
      'itemPrice': itemPrice,
      'options': options,
      'quantity': quantity,
    });
  }

  /// Updates the quantity of a line item in the current order on the server.
  ///
  /// Passing [quantity] of 0 removes the item.
  void updateItemQuantity(String lineItemId, int quantity) {
    if (currentOrderId == null) return;
    _wsRpcClient.sendAction('updateItemQuantity', {
      'orderId': currentOrderId,
      'lineItemId': lineItemId,
      'quantity': quantity,
    });
  }

  /// Completes the current order on the server.
  void completeCurrentOrder() {
    if (currentOrderId == null) return;
    _wsRpcClient.sendAction('completeOrder', {'orderId': currentOrderId});
    _currentOrderId = null;
  }

  /// Cancels the WebSocket subscription and closes the orders stream.
  ///
  /// Call this when the repository is no longer needed.
  Future<void> dispose() async {
    await _ordersWsSub?.cancel();
    await _ordersSubject?.close();
    _ordersWsSub = null;
    _ordersSubject = null;
  }

  void _initOrdersIfNeeded() {
    if (_ordersSubject != null) return;

    _ordersSubject = BehaviorSubject.seeded(const Orders(orders: []));

    _ordersWsSub = _wsRpcClient.subscribe('orders').listen((payload) {
      final orderList = payload['orders'] as List<dynamic>?;
      if (orderList == null) return;

      final orders = orderList
          .map((e) => OrderMapper.fromMap(e as Map<String, dynamic>))
          .toList();
      _ordersSubject?.add(Orders(orders: orders));
    });
  }
}
