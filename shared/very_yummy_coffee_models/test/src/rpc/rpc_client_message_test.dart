import 'package:test/test.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

void main() {
  group('RpcClientMessage', () {
    group('RpcSubscribeMessage', () {
      test('toMap produces correct wire format', () {
        const message = RpcSubscribeMessage(topic: 'menu');
        expect(message.toMap(), {
          'type': 'subscribe',
          'topic': 'menu',
        });
      });

      test('fromMap roundtrips correctly', () {
        const original = RpcSubscribeMessage(topic: 'orders');
        final map = original.toMap();
        final decoded = RpcClientMessageMapper.fromMap(map);
        expect(decoded, isA<RpcSubscribeMessage>());
        expect((decoded as RpcSubscribeMessage).topic, 'orders');
      });
    });

    group('RpcUnsubscribeMessage', () {
      test('toMap produces correct wire format', () {
        const message = RpcUnsubscribeMessage(topic: 'menu');
        expect(message.toMap(), {
          'type': 'unsubscribe',
          'topic': 'menu',
        });
      });

      test('fromMap roundtrips correctly', () {
        const original = RpcUnsubscribeMessage(topic: 'menu');
        final map = original.toMap();
        final decoded = RpcClientMessageMapper.fromMap(map);
        expect(decoded, isA<RpcUnsubscribeMessage>());
        expect((decoded as RpcUnsubscribeMessage).topic, 'menu');
      });
    });

    group('RpcActionClientMessage', () {
      test('toMap produces correct wire format', () {
        const message = RpcActionClientMessage(
          action: 'createOrder',
          payload: {'id': '123'},
        );
        expect(message.toMap(), {
          'type': 'action',
          'action': 'createOrder',
          'payload': {'id': '123'},
        });
      });

      test('fromMap roundtrips correctly', () {
        const original = RpcActionClientMessage(
          action: 'addItemToOrder',
          payload: {'orderId': 'o1', 'itemName': 'Latte'},
        );
        final map = original.toMap();
        final decoded = RpcClientMessageMapper.fromMap(map);
        expect(decoded, isA<RpcActionClientMessage>());
        final action = decoded as RpcActionClientMessage;
        expect(action.action, 'addItemToOrder');
        expect(action.payload['orderId'], 'o1');
        expect(action.payload['itemName'], 'Latte');
      });
    });

    group('fromMap dispatches to correct subtype', () {
      test('subscribe type dispatches to RpcSubscribeMessage', () {
        final decoded = RpcClientMessageMapper.fromMap({
          'type': 'subscribe',
          'topic': 'menu',
        });
        expect(decoded, isA<RpcSubscribeMessage>());
      });

      test('unsubscribe type dispatches to RpcUnsubscribeMessage', () {
        final decoded = RpcClientMessageMapper.fromMap({
          'type': 'unsubscribe',
          'topic': 'orders',
        });
        expect(decoded, isA<RpcUnsubscribeMessage>());
      });

      test('action type dispatches to RpcActionClientMessage', () {
        final decoded = RpcClientMessageMapper.fromMap({
          'type': 'action',
          'action': 'createOrder',
          'payload': <String, dynamic>{'id': '123'},
        });
        expect(decoded, isA<RpcActionClientMessage>());
      });
    });
  });
}
