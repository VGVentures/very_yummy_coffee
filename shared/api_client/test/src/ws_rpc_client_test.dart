import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';
import 'package:web_socket_client/web_socket_client.dart';

class _MockLiveConnection extends Mock
    implements LiveConnection<Map<String, dynamic>> {}

WsRpcClient _buildClient(LiveConnection<Map<String, dynamic>> connection) =>
    WsRpcClient.fromConnection(connection: connection);

void main() {
  group('WsRpcClient', () {
    late _MockLiveConnection connection;
    late StreamController<Map<String, dynamic>> messageController;
    late StreamController<ConnectionState> connectionStateController;

    setUp(() {
      connection = _MockLiveConnection();
      messageController = StreamController<Map<String, dynamic>>.broadcast();
      connectionStateController = StreamController<ConnectionState>.broadcast();

      when(() => connection.stream).thenAnswer((_) => messageController.stream);
      when(
        () => connection.connection,
      ).thenAnswer((_) => connectionStateController.stream);
      when(() => connection.send(any<dynamic>())).thenReturn(null);
      when(() => connection.close()).thenReturn(null);
    });

    tearDown(() async {
      await messageController.close();
      await connectionStateController.close();
    });

    group('subscribe', () {
      test('sends typed subscribe message on first call', () {
        _buildClient(connection).subscribe('menu');

        verify(
          () =>
              connection.send(const RpcSubscribeMessage(topic: 'menu').toMap()),
        ).called(1);
      });

      test(
        'returns an equivalent stream on repeated calls for the same topic',
        () async {
          final client = _buildClient(connection);
          final events1 = <Map<String, dynamic>>[];
          final events2 = <Map<String, dynamic>>[];
          final sub1 = client.subscribe('menu').listen(events1.add);
          final sub2 = client.subscribe('menu').listen(events2.add);

          messageController.add({
            'type': 'update',
            'topic': 'menu',
            'payload': <String, dynamic>{'key': 'value'},
          });
          await Future<void>.delayed(Duration.zero);

          expect(events1, [
            <String, dynamic>{'key': 'value'},
          ]);
          expect(events2, [
            <String, dynamic>{'key': 'value'},
          ]);
          await sub1.cancel();
          await sub2.cancel();
        },
      );

      test('does not send a duplicate subscribe message on repeated calls', () {
        _buildClient(connection)
          ..subscribe('menu')
          ..subscribe('menu');

        verify(
          () =>
              connection.send(const RpcSubscribeMessage(topic: 'menu').toMap()),
        ).called(1);
      });

      test(
        'routes incoming update messages to the correct topic stream',
        () async {
          final client = _buildClient(connection);
          final events = <Map<String, dynamic>>[];
          final sub = client.subscribe('orders').listen(events.add);

          messageController.add({
            'type': 'update',
            'topic': 'orders',
            'payload': <String, dynamic>{'orders': <dynamic>[]},
          });
          await Future<void>.delayed(Duration.zero);

          expect(events, [
            <String, dynamic>{'orders': <dynamic>[]},
          ]);
          await sub.cancel();
        },
      );
    });

    group('unsubscribe', () {
      test('sends typed unsubscribe message', () {
        _buildClient(connection)
          ..subscribe('menu')
          ..unsubscribe('menu');

        verify(
          () => connection.send(
            const RpcUnsubscribeMessage(topic: 'menu').toMap(),
          ),
        ).called(1);
      });
    });

    group('reconnect re-subscription', () {
      test('re-sends typed subscribe messages for all active topics '
          'on Reconnected', () async {
        _buildClient(connection)
          ..subscribe('menu')
          ..subscribe('orders');

        connectionStateController.add(const Reconnected());
        await Future<void>.delayed(Duration.zero);

        verify(
          () =>
              connection.send(const RpcSubscribeMessage(topic: 'menu').toMap()),
        ).called(2);
        verify(
          () => connection.send(
            const RpcSubscribeMessage(topic: 'orders').toMap(),
          ),
        ).called(2);
      });

      test('does not re-send for non-Reconnected connection states', () async {
        _buildClient(connection).subscribe('menu');

        connectionStateController.add(const Connected());
        await Future<void>.delayed(Duration.zero);

        verify(
          () =>
              connection.send(const RpcSubscribeMessage(topic: 'menu').toMap()),
        ).called(1);
      });
    });

    group('sendAction', () {
      test('sends typed action with correct JSON format', () {
        _buildClient(
          connection,
        ).sendAction(const CreateOrderAction(id: 'abc-123'));

        verify(
          () => connection.send({
            'type': 'action',
            'action': 'createOrder',
            'payload': {'id': 'abc-123'},
          }),
        ).called(1);
      });
    });

    group('close', () {
      test('cancels subscriptions and closes connection', () {
        _buildClient(connection)
          ..subscribe('menu')
          ..close();

        verify(() => connection.close()).called(1);
      });
    });
  });
}
