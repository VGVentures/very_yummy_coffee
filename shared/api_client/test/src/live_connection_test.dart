import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:web_socket_client/web_socket_client.dart';

class _MockWebSocket extends Mock implements WebSocket {}

void main() {
  group('LiveConnection', () {
    late WebSocket mockSocket;
    late StreamController<String> messageController;
    const testScheme = 'ws';
    const testHost = 'localhost';
    const testPort = 1234;
    const testPath = '/test';
    const testResponse = 'ok';
    String fromJson(String json) => json;

    setUp(() {
      mockSocket = _MockWebSocket();
      messageController = StreamController<String>.broadcast();
      when(
        () => mockSocket.messages,
      ).thenAnswer((_) => messageController.stream);
      when(() => mockSocket.send(any<dynamic>())).thenReturn(null);
      when(() => mockSocket.close()).thenAnswer((_) async {});
    });

    tearDown(() async {
      await messageController.close();
    });

    test('can be instantiated', () {
      final connection = LiveConnection<String>(
        scheme: testScheme,
        host: testHost,
        port: testPort,
        path: testPath,
        responseFromJson: fromJson,
        socket: mockSocket,
      );
      expect(connection, isNotNull);
    });

    test('maps incoming messages to objects using fromJson', () async {
      final connection = LiveConnection<String>(
        scheme: testScheme,
        host: testHost,
        port: testPort,
        path: testPath,
        responseFromJson: fromJson,
        socket: mockSocket,
      );
      final results = <String>[];
      final sub = connection.stream.listen(results.add);
      messageController.add(testResponse);
      await Future<void>.delayed(Duration.zero);
      expect(results, ['ok']);
      await sub.cancel();
    });

    test('send encodes and sends the request', () {
      final connection = LiveConnection<String>(
        scheme: testScheme,
        host: testHost,
        port: testPort,
        path: testPath,
        responseFromJson: fromJson,
        socket: mockSocket,
      );
      final request = {'foo': 'bar'};
      connection.send(request);
      verify(() => mockSocket.send(jsonEncode(request))).called(1);
    });

    test('close closes the socket', () async {
      LiveConnection<String>(
        scheme: testScheme,
        host: testHost,
        port: testPort,
        path: testPath,
        responseFromJson: fromJson,
        socket: mockSocket,
      ).close();
      verify(() => mockSocket.close()).called(1);
    });
  });
}
