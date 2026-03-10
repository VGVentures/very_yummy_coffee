import 'package:meta/meta.dart';

/// Typed RPC actions for the WebSocket protocol.
///
/// Each subtype represents a specific server action with typed payload fields.
/// Repositories construct these and pass them to `WsRpcClient.sendAction`,
/// which serializes them to the wire format.
@immutable
sealed class RpcAction {
  const RpcAction();

  /// The wire-format action name (e.g., 'createOrder').
  String get actionName;

  /// Serializes the action's payload fields to a map.
  Map<String, dynamic> toPayloadMap();
}

/// Creates a new order with the given [id].
class CreateOrderAction extends RpcAction {
  const CreateOrderAction({required this.id});

  final String id;

  @override
  String get actionName => 'createOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {'id': id};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CreateOrderAction && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Adds an item to an order.
class AddItemToOrderAction extends RpcAction {
  const AddItemToOrderAction({
    required this.orderId,
    required this.lineItemId,
    required this.itemName,
    required this.itemPrice,
    this.menuItemId,
    this.modifiers = const [],
    this.quantity = 1,
  });

  final String orderId;
  final String lineItemId;
  final String itemName;
  final int itemPrice;
  final String? menuItemId;
  final List<Map<String, dynamic>> modifiers;
  final int quantity;

  @override
  String get actionName => 'addItemToOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {
    'orderId': orderId,
    'lineItemId': lineItemId,
    'itemName': itemName,
    'itemPrice': itemPrice,
    'menuItemId': menuItemId,
    'modifiers': modifiers,
    'quantity': quantity,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddItemToOrderAction &&
          other.orderId == orderId &&
          other.lineItemId == lineItemId &&
          other.itemName == itemName &&
          other.itemPrice == itemPrice &&
          other.menuItemId == menuItemId &&
          other.quantity == quantity;

  @override
  int get hashCode => Object.hash(
    orderId,
    lineItemId,
    itemName,
    itemPrice,
    menuItemId,
    quantity,
  );
}

/// Updates the quantity of a line item in an order.
///
/// Passing [quantity] of 0 removes the item.
class UpdateItemQuantityAction extends RpcAction {
  const UpdateItemQuantityAction({
    required this.orderId,
    required this.lineItemId,
    required this.quantity,
  });

  final String orderId;
  final String lineItemId;
  final int quantity;

  @override
  String get actionName => 'updateItemQuantity';

  @override
  Map<String, dynamic> toPayloadMap() => {
    'orderId': orderId,
    'lineItemId': lineItemId,
    'quantity': quantity,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateItemQuantityAction &&
          other.orderId == orderId &&
          other.lineItemId == lineItemId &&
          other.quantity == quantity;

  @override
  int get hashCode => Object.hash(orderId, lineItemId, quantity);
}

/// Submits the order (pending -> submitted).
class SubmitOrderAction extends RpcAction {
  const SubmitOrderAction({required this.orderId});

  final String orderId;

  @override
  String get actionName => 'submitOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {'orderId': orderId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitOrderAction && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

/// Starts working on the order (submitted -> inProgress).
class StartOrderAction extends RpcAction {
  const StartOrderAction({required this.orderId});

  final String orderId;

  @override
  String get actionName => 'startOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {'orderId': orderId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartOrderAction && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

/// Marks the order as ready (inProgress -> ready).
class MarkOrderReadyAction extends RpcAction {
  const MarkOrderReadyAction({required this.orderId});

  final String orderId;

  @override
  String get actionName => 'markOrderReady';

  @override
  Map<String, dynamic> toPayloadMap() => {'orderId': orderId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkOrderReadyAction && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

/// Completes the order (ready -> completed).
class CompleteOrderAction extends RpcAction {
  const CompleteOrderAction({required this.orderId});

  final String orderId;

  @override
  String get actionName => 'completeOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {'orderId': orderId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompleteOrderAction && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

/// Cancels the order.
class CancelOrderAction extends RpcAction {
  const CancelOrderAction({required this.orderId});

  final String orderId;

  @override
  String get actionName => 'cancelOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {'orderId': orderId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CancelOrderAction && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

/// Updates the customer name on an order.
class UpdateNameOnOrderAction extends RpcAction {
  const UpdateNameOnOrderAction({
    required this.orderId,
    this.customerName,
  });

  final String orderId;
  final String? customerName;

  @override
  String get actionName => 'updateNameOnOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {
    'orderId': orderId,
    'customerName': customerName,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateNameOnOrderAction &&
          other.orderId == orderId &&
          other.customerName == customerName;

  @override
  int get hashCode => Object.hash(orderId, customerName);
}

/// Updates the availability of a menu item.
class UpdateMenuItemAvailabilityAction extends RpcAction {
  const UpdateMenuItemAvailabilityAction({
    required this.itemId,
    required this.available,
  });

  final String itemId;
  final bool available;

  @override
  String get actionName => 'updateMenuItemAvailability';

  @override
  Map<String, dynamic> toPayloadMap() => {
    'itemId': itemId,
    'available': available,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateMenuItemAvailabilityAction &&
          other.itemId == itemId &&
          other.available == available;

  @override
  int get hashCode => Object.hash(itemId, available);
}
