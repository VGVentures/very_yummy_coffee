import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:collection/collection.dart';
import 'package:order_repository/order_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

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
  /// Sets [currentOrderId] synchronously before yielding to the event loop,
  /// so even if multiple async callers race, only the first sees `null`.
  /// Derived streams reflect the new order once the server broadcasts the
  /// update.
  Future<void> createOrder() async {
    final id = _uuid.v4();
    _currentOrderId = id;
    _wsRpcClient.sendAction(CreateOrderAction(id: id));
  }

  /// Adds an item to the current order on the server.
  ///
  /// Auto-creates an order if [currentOrderId] is null, so callers never
  /// need to check or call [createOrder] themselves.
  Future<void> addItemToCurrentOrder({
    required String itemName,
    required int itemPrice,
    required int quantity,
    String? menuItemId,
    List<SelectedModifier> modifiers = const [],
  }) async {
    if (_currentOrderId == null) {
      await createOrder();
    }
    assert(_currentOrderId != null, 'createOrder must set _currentOrderId');
    _wsRpcClient.sendAction(
      AddItemToOrderAction(
        orderId: currentOrderId!,
        lineItemId: _uuid.v4(),
        itemName: itemName,
        itemPrice: itemPrice,
        menuItemId: menuItemId,
        modifiers: modifiers.map((m) => m.toMap()).toList(),
        quantity: quantity,
      ),
    );
  }

  /// Updates the quantity of a line item in the current order on the server.
  ///
  /// Passing [quantity] of 0 removes the item.
  void updateItemQuantity(String lineItemId, int quantity) {
    if (currentOrderId == null) return;
    _wsRpcClient.sendAction(
      UpdateItemQuantityAction(
        orderId: currentOrderId!,
        lineItemId: lineItemId,
        quantity: quantity,
      ),
    );
  }

  /// Updates the customer name on the current order.
  ///
  /// No-op if [currentOrderId] is null. The name is trimmed; if empty after
  /// trimming, `null` is sent to clear the name.
  Future<void> updateNameOnCurrentOrder(String customerName) async {
    if (_currentOrderId == null) return;
    final trimmed = customerName.trim();
    _wsRpcClient.sendAction(
      UpdateNameOnOrderAction(
        orderId: _currentOrderId!,
        customerName: trimmed.isEmpty ? null : trimmed,
      ),
    );
  }

  /// Submits the current order on the server (pending -> submitted).
  ///
  /// Sends a `submitOrder` WS action and clears [currentOrderId].
  /// No-op if [currentOrderId] is null.
  void submitCurrentOrder() {
    final orderId = _currentOrderId;
    if (orderId == null) return;
    _wsRpcClient.sendAction(SubmitOrderAction(orderId: orderId));
    _currentOrderId = null;
  }

  /// Completes the current order on the server.
  void completeCurrentOrder() {
    if (currentOrderId == null) return;
    _wsRpcClient.sendAction(CompleteOrderAction(orderId: currentOrderId!));
    _currentOrderId = null;
  }

  /// Transitions order from submitted -> inProgress on the server.
  void startOrder(String orderId) {
    _wsRpcClient.sendAction(StartOrderAction(orderId: orderId));
  }

  /// Transitions order from inProgress -> ready on the server.
  void markOrderReady(String orderId) {
    _wsRpcClient.sendAction(MarkOrderReadyAction(orderId: orderId));
  }

  /// Transitions a specific order to completed (KDS-facing, orderId-based).
  ///
  /// Distinct from [completeCurrentOrder] which clears the customer's tracked
  /// order ID. Use this when completing orders by explicit ID (e.g., KDS).
  void markOrderCompleted(String orderId) {
    _wsRpcClient.sendAction(CompleteOrderAction(orderId: orderId));
  }

  /// Cancels a specific order by orderId.
  void cancelOrder(String orderId) {
    _wsRpcClient.sendAction(CancelOrderAction(orderId: orderId));
  }

  /// Sets an existing order as the current order without sending any RPC
  /// action.
  ///
  /// Use this to resume editing a pending order that was previously created.
  /// The [currentOrderStream] (derived from [ordersStream]) will start
  /// emitting the matching order on the next server broadcast.
  void setCurrentOrderId(String orderId) {
    assert(orderId.isNotEmpty, 'orderId must not be empty');
    _currentOrderId = orderId;
  }

  /// Cancels the current order and clears the tracked order ID.
  ///
  /// Use on the POS "Clear" action. Unlike [cancelOrder], this also
  /// sets [currentOrderId] to null so [currentOrderStream] stops emitting.
  void clearCurrentOrder() {
    final orderId = _currentOrderId;
    if (orderId == null) return;
    _wsRpcClient.sendAction(CancelOrderAction(orderId: orderId));
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

    _ordersWsSub = _wsRpcClient.subscribe(RpcTopics.orders).listen((payload) {
      final orderList = payload['orders'] as List<dynamic>?;
      if (orderList == null) return;

      final orders = orderList
          .map((e) => OrderMapper.fromMap(e as Map<String, dynamic>))
          .toList();
      _ordersSubject?.add(Orders(orders: orders));
    });
  }
}
