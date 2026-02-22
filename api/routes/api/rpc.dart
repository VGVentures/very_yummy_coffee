import 'dart:convert';
import 'dart:developer';

import 'package:api/src/server_state.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Handler get onRequest => webSocketHandler((channel, protocol) {
      log('[rpc] client connected');
      final sink = channel.sink;

      channel.stream.listen(
        (message) {
          log('[rpc] received: $message');
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final type = json['type'] as String?;

          switch (type) {
            case 'subscribe':
              final topic = json['topic'] as String;
              log('[rpc] subscribe: $topic');
              serverState.subscribe(topic, sink);
              sink.add(
                jsonEncode({
                  'type': 'update',
                  'topic': topic,
                  'payload': serverState.snapshotForTopic(topic),
                }),
              );

            case 'unsubscribe':
              log('[rpc] unsubscribe: ${json['topic']}');
              serverState.unsubscribe(json['topic'] as String, sink);

            case 'action':
              log('[rpc] action: ${json['action']}');
              serverState.handleAction(
                json['action'] as String,
                json['payload'] as Map<String, dynamic>,
              );
          }
        },
        onDone: () {
          log('[rpc] client disconnected');
          serverState.removeAllSubscriptions(sink);
        },
      );
    });
