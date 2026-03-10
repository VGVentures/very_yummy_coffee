import 'package:dart_mappable/dart_mappable.dart';

part 'rpc_client_message.mapper.dart';

/// Typed client-to-server WebSocket messages.
///
/// The server parses incoming JSON into one of these subtypes via
/// `RpcClientMessageMapper.fromMap`, then pattern-matches to handle
/// subscribe, unsubscribe, and action messages.
@MappableClass(discriminatorKey: 'type')
sealed class RpcClientMessage with RpcClientMessageMappable {
  const RpcClientMessage();
}

/// Subscribes to a WebSocket topic.
@MappableClass(discriminatorValue: 'subscribe')
class RpcSubscribeMessage extends RpcClientMessage
    with RpcSubscribeMessageMappable {
  const RpcSubscribeMessage({required this.topic});

  final String topic;
}

/// Unsubscribes from a WebSocket topic.
@MappableClass(discriminatorValue: 'unsubscribe')
class RpcUnsubscribeMessage extends RpcClientMessage
    with RpcUnsubscribeMessageMappable {
  const RpcUnsubscribeMessage({required this.topic});

  final String topic;
}

/// An action message containing an action name and payload.
///
/// Repositories never construct this directly — they construct typed
/// `RpcAction` subtypes. `WsRpcClient.sendAction` wraps the `RpcAction`
/// into an `RpcActionClientMessage` internally.
@MappableClass(discriminatorValue: 'action')
class RpcActionClientMessage extends RpcClientMessage
    with RpcActionClientMessageMappable {
  const RpcActionClientMessage({
    required this.action,
    required this.payload,
  });

  final String action;
  final Map<String, dynamic> payload;
}
