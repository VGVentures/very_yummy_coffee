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
  bool _menuLoaded = false;

  // orderId -> order map (raw JSON-compatible maps)
  final Map<String, Map<String, dynamic>> _orders = {};

  // topic -> set of connected sinks
  final Map<String, Set<StreamSink<dynamic>>> _subs = {};

  /// Loads menu data from the fixture file if not already loaded.
  void loadMenuIfNeeded() {
    if (_menuLoaded) return;
    final fixture = jsonDecode(
      File('fixtures/menu.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    _menuGroups = (fixture['groups'] as List<dynamic>).map((e) {
      final map = e as Map<String, dynamic>;
      // Ensure the group can be serialized via the mapper to validate data
      MenuGroupMapper.fromMap(map);
      return map;
    }).toList();
    _menuItems = (fixture['items'] as List<dynamic>).map((e) {
      final map = e as Map<String, dynamic>;
      MenuItemMapper.fromMap(map);
      return map;
    }).toList();
    _menuLoaded = true;
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
      loadMenuIfNeeded();
      return {'groups': _menuGroups, 'items': _menuItems};
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
        };
        broadcast('orders', snapshotForTopic('orders'));

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
                });
          _orders[orderId] = <String, dynamic>{...order, 'items': items};
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'removeItemFromOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null) {
          final items =
              List<Map<String, dynamic>>.from(order['items'] as List<dynamic>)
                ..removeWhere(
                  (item) => item['id'] == payload['lineItemId'] as String,
                );
          _orders[orderId] = <String, dynamic>{...order, 'items': items};
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'completeOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null) {
          _orders[orderId] = <String, dynamic>{...order, 'status': 'completed'};
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }

      case 'cancelOrder':
        final orderId = payload['orderId'] as String;
        final order = _orders[orderId];
        if (order != null) {
          _orders[orderId] = <String, dynamic>{...order, 'status': 'cancelled'};
          broadcast('orders', snapshotForTopic('orders'));
          broadcast('order:$orderId', _orders[orderId]!);
        }
    }
  }
}

/// The global singleton server state instance.
final serverState = ServerState();
