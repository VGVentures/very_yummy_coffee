import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

/// {@template server_state}
/// In-memory server state for the RPC WebSocket layer.
///
/// Holds the current menu and orders, and manages topic subscriptions.
/// A single [serverState] singleton is shared across all WebSocket connections.
/// {@endtemplate}
class ServerState {
  List<Map<String, dynamic>> _menuGroups = [];
  List<Map<String, dynamic>> _menuItems = [];
  List<Map<String, dynamic>> _modifierGroups = [];

  // orderId -> order map (raw JSON-compatible maps)
  final Map<String, Map<String, dynamic>> _orders = {};

  // topic -> set of connected sinks
  final Map<String, Set<StreamSink<dynamic>>> _subs = {};

  /// Loads menu data from the fixture file. Called once at server startup.
  void loadMenu() {
    final fixture = jsonDecode(
      File('fixtures/menu.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    _menuGroups = (fixture['groups'] as List<dynamic>).map((e) {
      final map = e as Map<String, dynamic>;
      MenuGroupMapper.fromMap(map);
      return map;
    }).toList();
    _menuItems = (fixture['items'] as List<dynamic>).map((e) {
      final map = e as Map<String, dynamic>;
      MenuItemMapper.fromMap(map);
      return map;
    }).toList();
    _modifierGroups = (fixture['modifierGroups'] as List<dynamic>?)?.map((e) {
          final map = e as Map<String, dynamic>;
          ModifierGroupMapper.fromMap(map);
          return map;
        }).toList() ??
        [];
  }

  /// Adds [sink] as a subscriber to [topic].
  void subscribe(String topic, StreamSink<dynamic> sink) {
    _subs.putIfAbsent(topic, () => {}).add(sink);
  }

  /// Removes [sink] from [topic] subscribers.
  void unsubscribe(String topic, StreamSink<dynamic> sink) {
    _subs[topic]?.remove(sink);
  }

  /// Removes [sink] from all topic subscriptions (called on disconnect).
  void removeAllSubscriptions(StreamSink<dynamic> sink) {
    for (final sinks in _subs.values) {
      sinks.remove(sink);
    }
  }

  /// Broadcasts [payload] to all subscribers of [topic].
  void broadcast(String topic, Map<String, dynamic> payload) {
    final message = jsonEncode({
      'type': 'update',
      'topic': topic,
      'payload': payload,
    });
    final subscribers = _subs[topic];
    if (subscribers == null || subscribers.isEmpty) return;
    for (final sink in List.of(subscribers)) {
      sink.add(message);
    }
  }

  /// Returns a snapshot of the current state for [topic].
  Map<String, dynamic> snapshotForTopic(String topic) {
    if (topic == 'menu') {
      return {
        'groups': _menuGroups,
        'items': _menuItems,
        'modifierGroups': _modifierGroups,
      };
    }
    if (topic == 'orders') {
      return {'orders': _orders.values.toList()};
    }
    if (topic.startsWith('order:')) {
      final orderId = topic.substring(6);
      return _orders[orderId] ?? {};
    }
    return {};
  }

  /// Processes an [action] with [payload], updates state, and broadcasts.
  void handleAction(String action, Map<String, dynamic> payload) {
    switch (action) {
      case 'updateMenuItemAvailability':
        final itemId = payload['itemId'] as String;
        final available = payload['available'] as bool;
        _menuItems = _menuItems.map((item) {
          if (item['id'] == itemId) {
            return <String, dynamic>{...item, 'available': available};
          }
          return item;
        }).toList();
        broadcast('menu', snapshotForTopic('menu'));

      case 'createOrder':
        final id = payload['id'] as String;
        _orders[id] = {
          'id': id,
          'items': <Map<String, dynamic>>[],
          'status': 'pending',
          'customerName': null,
        };
        broadcast('orders', snapshotForTopic('orders'));

      case 'updateNameOnOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null && order['status'] == 'pending') {
          final name = payload['customerName'] as String?;
          _orders[orderId] = <String, dynamic>{
            ...order,
            'customerName': (name != null && name.isEmpty) ? null : name,
          };
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'addItemToOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null) {
          final items =
              List<Map<String, dynamic>>.from(order['items'] as List<dynamic>)
                ..add({
                  'id': payload['lineItemId'] as String,
                  'name': payload['itemName'] as String,
                  'price': payload['itemPrice'] as int,
                  'menuItemId': payload['menuItemId'] as String?,
                  'modifiers':
                      payload['modifiers'] as List<dynamic>? ?? const [],
                  'quantity': payload['quantity'] as int? ?? 1,
                });
          _orders[orderId] = <String, dynamic>{...order, 'items': items};
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'updateItemQuantity':
        final orderId = payload['orderId'] as String;
        final lineItemId = payload['lineItemId'] as String;
        final quantity = payload['quantity'] as int;
        final order = _orders[orderId];
        if (order != null) {
          final items = List<Map<String, dynamic>>.from(
            order['items'] as List<dynamic>,
          );
          if (quantity == 0) {
            items.removeWhere((item) => item['id'] == lineItemId);
          } else {
            final idx = items.indexWhere((item) => item['id'] == lineItemId);
            if (idx != -1) items[idx] = {...items[idx], 'quantity': quantity};
          }
          _orders[orderId] = <String, dynamic>{...order, 'items': items};
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'submitOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null) {
          _orders[orderId] = <String, dynamic>{
            ...order,
            'status': 'submitted',
            'submittedAt': DateTime.now().toUtc().toIso8601String(),
          };
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'startOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null && order['status'] == 'submitted') {
          _orders[orderId] = <String, dynamic>{
            ...order,
            'status': 'inProgress',
          };
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'markOrderReady':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null && order['status'] == 'inProgress') {
          _orders[orderId] = <String, dynamic>{...order, 'status': 'ready'};
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'completeOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null && order['status'] == 'ready') {
          _orders[orderId] = <String, dynamic>{
            ...order,
            'status': 'completed',
          };
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'cancelOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null &&
            order['status'] != 'completed' &&
            order['status'] != 'cancelled') {
          _orders[orderId] = <String, dynamic>{
            ...order,
            'status': 'cancelled',
          };
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }
    }
  }
}

/// The global singleton server state instance.
final serverState = ServerState();
