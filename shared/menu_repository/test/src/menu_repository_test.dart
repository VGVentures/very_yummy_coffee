import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockWsRpcClient extends Mock implements WsRpcClient {}

void main() {
  group('MenuRepository', () {
    test('can be instantiated', () {
      expect(
        MenuRepository(wsRpcClient: _MockWsRpcClient()),
        isNotNull,
      );
    });

    group('getMenuItem', () {
      late WsRpcClient wsRpcClient;
      late StreamController<Map<String, dynamic>> wsController;

      const groupId = 'drinks';
      const itemId = '1';

      final menuPayload = {
        'groups': [
          {
            'id': groupId,
            'name': 'Drinks',
            'description': 'Coffee, tea & beverages',
            'color': 4292866518,
          },
        ],
        'items': [
          {
            'id': itemId,
            'name': 'Espresso',
            'price': 300,
            'groupId': groupId,
            'available': true,
          },
          {
            'id': '2',
            'name': 'Latte',
            'price': 475,
            'groupId': groupId,
            'available': true,
          },
        ],
      };

      setUp(() {
        wsRpcClient = _MockWsRpcClient();
        wsController = StreamController<Map<String, dynamic>>.broadcast();
        when(
          () => wsRpcClient.subscribe('menu'),
        ).thenAnswer((_) => wsController.stream);
        when(() => wsRpcClient.unsubscribe(any())).thenReturn(null);
      });

      tearDown(() => wsController.close());

      test('emits matching item when found', () {
        final repo = MenuRepository(wsRpcClient: wsRpcClient);

        expect(
          repo.getMenuItem(groupId, itemId),
          emits(
            isA<MenuItem>()
                .having((i) => i.id, 'id', itemId)
                .having((i) => i.name, 'name', 'Espresso')
                .having((i) => i.price, 'price', 300),
          ),
        );

        wsController.add(menuPayload);
      });

      test('emits null when item id is not found in group', () {
        final repo = MenuRepository(wsRpcClient: wsRpcClient);

        expect(
          repo.getMenuItem(groupId, 'unknown-id'),
          emits(isNull),
        );

        wsController.add(menuPayload);
      });

      test('emits null when group id does not match any items', () {
        final repo = MenuRepository(wsRpcClient: wsRpcClient);

        expect(
          repo.getMenuItem('unknown-group', itemId),
          emits(isNull),
        );

        wsController.add(menuPayload);
      });

      test('emits updated availability when item toggled', () {
        final repo = MenuRepository(wsRpcClient: wsRpcClient);

        final updatedPayload = {
          'groups': menuPayload['groups'],
          'items': [
            {
              'id': itemId,
              'name': 'Espresso',
              'price': 300,
              'groupId': groupId,
              'available': false,
            },
          ],
        };

        expect(
          repo.getMenuItem(groupId, itemId),
          emitsInOrder([
            isA<MenuItem>().having((i) => i.available, 'available', true),
            isA<MenuItem>().having((i) => i.available, 'available', false),
          ]),
        );

        wsController
          ..add(menuPayload)
          ..add(updatedPayload);
      });

      test('emits updated item when stream emits again', () async {
        final repo = MenuRepository(wsRpcClient: wsRpcClient);

        final updatedPayload = {
          'groups': menuPayload['groups'],
          'items': [
            {
              'id': itemId,
              'name': 'Espresso',
              'price': 350,
              'groupId': groupId,
              'available': true,
            },
          ],
        };

        expect(
          repo.getMenuItem(groupId, itemId),
          emitsInOrder([
            isA<MenuItem>().having((i) => i.price, 'price', 300),
            isA<MenuItem>().having((i) => i.price, 'price', 350),
          ]),
        );

        wsController
          ..add(menuPayload)
          ..add(updatedPayload);
      });
    });

    group('setItemAvailability', () {
      late WsRpcClient wsRpcClient;

      setUp(() {
        wsRpcClient = _MockWsRpcClient();
      });

      test('sends updateMenuItemAvailability action with available false', () {
        final repo = MenuRepository(wsRpcClient: wsRpcClient);

        repo.setItemAvailability('101', available: false);

        verify(
          () => wsRpcClient.sendAction('updateMenuItemAvailability', {
            'itemId': '101',
            'available': false,
          }),
        ).called(1);
      });

      test('sends updateMenuItemAvailability action with available true', () {
        final repo = MenuRepository(wsRpcClient: wsRpcClient);

        repo.setItemAvailability('101', available: true);

        verify(
          () => wsRpcClient.sendAction('updateMenuItemAvailability', {
            'itemId': '101',
            'available': true,
          }),
        ).called(1);
      });
    });
  });
}
