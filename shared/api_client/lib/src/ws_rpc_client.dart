import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';

/// {@template ws_rpc_client}
/// A WebSocket-based RPC client that multiplexes multiple topic subscriptions
/// over a single persistent connection.
///
/// Use [subscribe] to receive a stream of updates for a given topic. If a
/// subscription already exists for the topic, the same broadcast stream is
/// returned, so multiple callers in the same application share one connection.
///
/// Use [sendAction] to send a mutation to the server, which will broadcast
/// the resulting state change to all subscribed clients.
///
/// Use [unsubscribe] when you no longer need updates for a topic. Call [close]
/// to tear down the connection entirely.
/// {@endtemplate}
class WsRpcClient {
  WsRpcClient._({required LiveConnection<Map<String, dynamic>> connection})
    : _connection = connection;

  /// Creates a [WsRpcClient] using an existing [ApiClient] for connection
  /// parameters (host, port, scheme).
  factory WsRpcClient.fromApiClient(ApiClient apiClient) {
    return WsRpcClient._(
      connection: apiClient.startLiveConnection(
        '/rpc',
        responseFromJson: (body) => jsonDecode(body) as Map<String, dynamic>,
      ),
    );
  }

  final LiveConnection<Map<String, dynamic>> _connection;
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};
  StreamSubscription<Map<String, dynamic>>? _inboundSub;

  /// Returns a broadcast stream of update payloads for [topic].
  ///
  /// If already subscribed, returns the existing stream. Otherwise, sends a
  /// subscribe message to the server and creates a new stream.
  Stream<Map<String, dynamic>> subscribe(String topic) {
    if (_controllers.containsKey(topic)) {
      return _controllers[topic]!.stream;
    }
    _controllers[topic] = StreamController<Map<String, dynamic>>.broadcast();
    _ensureListening();
    _connection.send({'type': 'subscribe', 'topic': topic});
    return _controllers[topic]!.stream;
  }

  /// Sends an unsubscribe message for [topic] and closes its stream.
  void unsubscribe(String topic) {
    _connection.send({'type': 'unsubscribe', 'topic': topic});
    _controllers.remove(topic)?.close();
  }

  /// Sends an action to the server, which processes it and broadcasts the
  /// updated state to all relevant topic subscribers.
  void sendAction(String action, Map<String, dynamic> payload) {
    _connection.send({'type': 'action', 'action': action, 'payload': payload});
  }

  /// Closes the connection and all topic streams.
  void close() {
    _inboundSub?.cancel();
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _connection.close();
  }

  void _ensureListening() {
    _inboundSub ??= _connection.stream.listen((message) {
      if (message['type'] == 'update') {
        final topic = message['topic'] as String?;
        final payload = message['payload'];
        if (topic != null && payload is Map<String, dynamic>) {
          _controllers[topic]?.add(payload);
        }
      }
    });
  }
}
