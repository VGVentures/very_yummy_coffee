import 'dart:convert';

import 'package:api/src/server_state.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Handler get onRequest => webSocketHandler((channel, protocol) {
      final sink = channel.sink;

      channel.stream.listen(
        (message) {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final type = json['type'] as String?;

          switch (type) {
            case 'subscribe':
              final topic = json['topic'] as String;
              serverState.subscribe(topic, sink);
              sink.add(
                jsonEncode({
                  'type': 'update',
                  'topic': topic,
                  'payload': serverState.snapshotForTopic(topic),
                }),
              );

            case 'unsubscribe':
              serverState.unsubscribe(json['topic'] as String, sink);

            case 'action':
              serverState.handleAction(
                json['action'] as String,
                json['payload'] as Map<String, dynamic>,
              );
          }
        },
        onDone: () => serverState.removeAllSubscriptions(sink),
      );
    });
