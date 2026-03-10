import 'package:test/test.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

/// Integration test: typed action -> serialize via WsRpcClient pattern ->
/// parse via RpcClientMessage.fromMap -> extract action/payload.
///
/// Verifies wire compatibility end-to-end.
void main() {
  group('RPC wire compatibility', () {
    test('typed action serializes and parses back correctly', () {
      // 1. Repository constructs typed action
      const action = AddItemToOrderAction(
        orderId: 'order-1',
        lineItemId: 'li-1',
        itemName: 'Latte',
        itemPrice: 500,
        menuItemId: '101',
        quantity: 2,
      );

      // 2. WsRpcClient serializes to map (same as sendAction internals)
      final wireMap = <String, dynamic>{
        'type': 'action',
        'action': action.actionName,
        'payload': action.toPayloadMap(),
      };

      // 3. Server parses via RpcClientMessageMapper.fromMap
      final parsed = RpcClientMessageMapper.fromMap(wireMap);

      // 4. Verify correct subtype and fields
      expect(parsed, isA<RpcActionClientMessage>());
      final msg = parsed as RpcActionClientMessage;
      expect(msg.action, 'addItemToOrder');
      expect(msg.payload['orderId'], 'order-1');
      expect(msg.payload['lineItemId'], 'li-1');
      expect(msg.payload['itemName'], 'Latte');
      expect(msg.payload['itemPrice'], 500);
      expect(msg.payload['menuItemId'], '101');
      expect(msg.payload['quantity'], 2);
    });

    test('subscribe message roundtrips correctly', () {
      const msg = RpcSubscribeMessage(topic: 'orders');
      final wireMap = msg.toMap();
      final parsed = RpcClientMessageMapper.fromMap(wireMap);

      expect(parsed, isA<RpcSubscribeMessage>());
      expect((parsed as RpcSubscribeMessage).topic, 'orders');
    });

    test('unsubscribe message roundtrips correctly', () {
      const msg = RpcUnsubscribeMessage(topic: 'menu');
      final wireMap = msg.toMap();
      final parsed = RpcClientMessageMapper.fromMap(wireMap);

      expect(parsed, isA<RpcUnsubscribeMessage>());
      expect((parsed as RpcUnsubscribeMessage).topic, 'menu');
    });

    test('all action types produce valid wire format', () {
      final actions = <RpcAction>[
        const CreateOrderAction(id: 'o1'),
        const AddItemToOrderAction(
          orderId: 'o1',
          lineItemId: 'li1',
          itemName: 'Espresso',
          itemPrice: 300,
        ),
        const UpdateItemQuantityAction(
          orderId: 'o1',
          lineItemId: 'li1',
          quantity: 3,
        ),
        const SubmitOrderAction(orderId: 'o1'),
        const StartOrderAction(orderId: 'o1'),
        const MarkOrderReadyAction(orderId: 'o1'),
        const CompleteOrderAction(orderId: 'o1'),
        const CancelOrderAction(orderId: 'o1'),
        const UpdateNameOnOrderAction(orderId: 'o1', customerName: 'Test'),
        const UpdateMenuItemAvailabilityAction(
          itemId: '101',
          available: false,
        ),
      ];

      for (final action in actions) {
        final wireMap = <String, dynamic>{
          'type': 'action',
          'action': action.actionName,
          'payload': action.toPayloadMap(),
        };

        final parsed = RpcClientMessageMapper.fromMap(wireMap);
        expect(
          parsed,
          isA<RpcActionClientMessage>(),
          reason: '${action.actionName} should parse as RpcActionClientMessage',
        );
        final msg = parsed as RpcActionClientMessage;
        expect(msg.action, action.actionName);
        expect(msg.payload, action.toPayloadMap());
      }
    });
  });
}
