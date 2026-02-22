import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:web_socket_client/web_socket_client.dart';

/// {@template live_connection}
/// A live connection to a server.
/// {@endtemplate}
class LiveConnection<From> {
  /// {@macro live_connection}
  LiveConnection({
    required String scheme,
    required String host,
    required int? port,
    required String path,
    required FromJson<From> responseFromJson,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
    Duration? pingInterval,
    Backoff? backoff,
    Duration? timeout,
    WebSocket? socket,
  }) : _responseFromJson = responseFromJson,
       _socket =
           socket ??
           WebSocket(
             Uri(
               scheme: scheme,
               host: host,
               port: port,
               path: path,
               queryParameters: queryParameters,
             ),
             headers: headers,
             pingInterval: pingInterval,
             backoff: backoff,
             timeout: timeout,
           );

  final WebSocket _socket;
  final FromJson<From> _responseFromJson;

  /// The stream of connection state changes.
  Stream<ConnectionState> get connection => _socket.connection;

  /// The stream of responses from the server.
  Stream<From> get stream => _socket.messages.map((event) {
    return _responseFromJson(event as String);
  });

  /// Sends a request to the server.
  void send(dynamic request) {
    _socket.send(jsonEncode(request));
  }

  /// Closes the connection.
  void close() {
    _socket.close();
  }
}
