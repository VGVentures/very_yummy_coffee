import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:connection_repository/connection_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockWsRpcClient extends Mock implements WsRpcClient {}

void main() {
  group('ConnectionRepository', () {
    late WsRpcClient wsRpcClient;

    setUp(() {
      wsRpcClient = _MockWsRpcClient();
    });

    test('can be instantiated', () {
      expect(
        ConnectionRepository(wsRpcClient: wsRpcClient),
        isNotNull,
      );
    });

    test('isConnected forwards stream from WsRpcClient', () {
      final controller = StreamController<bool>.broadcast();
      when(() => wsRpcClient.isConnected).thenAnswer((_) => controller.stream);

      final repo = ConnectionRepository(wsRpcClient: wsRpcClient);

      expect(repo.isConnected, emitsInOrder([true, false]));

      controller
        ..add(true)
        ..add(false);
    });
  });
}
