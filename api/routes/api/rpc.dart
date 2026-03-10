import 'dart:convert';
import 'dart:developer';

import 'package:api/src/server_state.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

Handler get onRequest => webSocketHandler((channel, protocol) {
      log('[rpc] client connected');
      final sink = channel.sink;

      channel.stream.listen(
        (message) {
          log('[rpc] received: $message');
          final json = jsonDecode(message as String) as Map<String, dynamic>;

          try {
            final msg = RpcClientMessageMapper.fromMap(json);
            switch (msg) {
              case RpcSubscribeMessage(:final topic):
                log('[rpc] subscribe: $topic');
                serverState.subscribe(topic, sink);
                sink.add(
                  jsonEncode({
                    'type': 'update',
                    'topic': topic,
                    'payload': serverState.snapshotForTopic(topic),
                  }),
                );

              case RpcUnsubscribeMessage(:final topic):
                log('[rpc] unsubscribe: $topic');
                serverState.unsubscribe(topic, sink);

              case RpcActionClientMessage(:final action, :final payload):
                log('[rpc] action: $action');
                serverState.handleAction(action, payload);
            }
          } on Exception catch (e) {
            log('[rpc] malformed message: $e');
          }
        },
        onDone: () {
          log('[rpc] client disconnected');
          serverState.removeAllSubscriptions(sink);
        },
      );
    });
