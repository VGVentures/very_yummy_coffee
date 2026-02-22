import 'package:api_client/api_client.dart';

/// {@template connection_repository}
/// A repository managing the WebSocket connection state.
///
/// Wraps [WsRpcClient] and exposes a [isConnected] stream so that BLoCs and
/// other consumers never need a direct reference to the RPC client.
/// {@endtemplate}
class ConnectionRepository {
  /// {@macro connection_repository}
  ConnectionRepository({required WsRpcClient wsRpcClient})
    : _wsRpcClient = wsRpcClient;

  final WsRpcClient _wsRpcClient;

  /// Emits `true` when the WebSocket is connected or reconnected,
  /// and `false` when it disconnects.
  Stream<bool> get isConnected => _wsRpcClient.isConnected;
}
