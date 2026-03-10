import 'package:test/test.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

void main() {
  group('RpcAction', () {
    group('CreateOrderAction', () {
      test('has correct actionName', () {
        const action = CreateOrderAction(id: '123');
        expect(action.actionName, 'createOrder');
      });

      test('toPayloadMap includes id', () {
        const action = CreateOrderAction(id: 'abc');
        expect(action.toPayloadMap(), {'id': 'abc'});
      });
    });

    group('AddItemToOrderAction', () {
      test('has correct actionName', () {
        const action = AddItemToOrderAction(
          orderId: 'o1',
          lineItemId: 'li1',
          itemName: 'Latte',
          itemPrice: 500,
        );
        expect(action.actionName, 'addItemToOrder');
      });

      test('toPayloadMap includes all fields', () {
        const action = AddItemToOrderAction(
          orderId: 'o1',
          lineItemId: 'li1',
          itemName: 'Latte',
          itemPrice: 500,
          menuItemId: '101',
          modifiers: [
            {'modifierGroupId': 'mg-1', 'options': <dynamic>[]},
          ],
          quantity: 2,
        );
        expect(action.toPayloadMap(), {
          'orderId': 'o1',
          'lineItemId': 'li1',
          'itemName': 'Latte',
          'itemPrice': 500,
          'menuItemId': '101',
          'modifiers': [
            {'modifierGroupId': 'mg-1', 'options': <dynamic>[]},
          ],
          'quantity': 2,
        });
      });

      test('toPayloadMap defaults menuItemId to null and quantity to 1', () {
        const action = AddItemToOrderAction(
          orderId: 'o1',
          lineItemId: 'li1',
          itemName: 'Espresso',
          itemPrice: 300,
        );
        final payload = action.toPayloadMap();
        expect(payload['menuItemId'], isNull);
        expect(payload['modifiers'], isEmpty);
        expect(payload['quantity'], 1);
      });
    });

    group('UpdateItemQuantityAction', () {
      test('has correct actionName', () {
        const action = UpdateItemQuantityAction(
          orderId: 'o1',
          lineItemId: 'li1',
          quantity: 3,
        );
        expect(action.actionName, 'updateItemQuantity');
      });

      test('toPayloadMap includes all fields', () {
        const action = UpdateItemQuantityAction(
          orderId: 'o1',
          lineItemId: 'li1',
          quantity: 0,
        );
        expect(action.toPayloadMap(), {
          'orderId': 'o1',
          'lineItemId': 'li1',
          'quantity': 0,
        });
      });
    });

    group('SubmitOrderAction', () {
      test('has correct actionName', () {
        const action = SubmitOrderAction(orderId: 'o1');
        expect(action.actionName, 'submitOrder');
      });

      test('toPayloadMap includes orderId', () {
        const action = SubmitOrderAction(orderId: 'o1');
        expect(action.toPayloadMap(), {'orderId': 'o1'});
      });
    });

    group('StartOrderAction', () {
      test('has correct actionName', () {
        const action = StartOrderAction(orderId: 'o1');
        expect(action.actionName, 'startOrder');
      });

      test('toPayloadMap includes orderId', () {
        const action = StartOrderAction(orderId: 'o1');
        expect(action.toPayloadMap(), {'orderId': 'o1'});
      });
    });

    group('MarkOrderReadyAction', () {
      test('has correct actionName', () {
        const action = MarkOrderReadyAction(orderId: 'o1');
        expect(action.actionName, 'markOrderReady');
      });

      test('toPayloadMap includes orderId', () {
        const action = MarkOrderReadyAction(orderId: 'o1');
        expect(action.toPayloadMap(), {'orderId': 'o1'});
      });
    });

    group('CompleteOrderAction', () {
      test('has correct actionName', () {
        const action = CompleteOrderAction(orderId: 'o1');
        expect(action.actionName, 'completeOrder');
      });

      test('toPayloadMap includes orderId', () {
        const action = CompleteOrderAction(orderId: 'o1');
        expect(action.toPayloadMap(), {'orderId': 'o1'});
      });
    });

    group('CancelOrderAction', () {
      test('has correct actionName', () {
        const action = CancelOrderAction(orderId: 'o1');
        expect(action.actionName, 'cancelOrder');
      });

      test('toPayloadMap includes orderId', () {
        const action = CancelOrderAction(orderId: 'o1');
        expect(action.toPayloadMap(), {'orderId': 'o1'});
      });
    });

    group('UpdateNameOnOrderAction', () {
      test('has correct actionName', () {
        const action = UpdateNameOnOrderAction(orderId: 'o1');
        expect(action.actionName, 'updateNameOnOrder');
      });

      test('toPayloadMap includes orderId and customerName', () {
        const action = UpdateNameOnOrderAction(
          orderId: 'o1',
          customerName: 'Marcus',
        );
        expect(action.toPayloadMap(), {
          'orderId': 'o1',
          'customerName': 'Marcus',
        });
      });

      test('toPayloadMap includes null customerName when omitted', () {
        const action = UpdateNameOnOrderAction(orderId: 'o1');
        expect(action.toPayloadMap(), {
          'orderId': 'o1',
          'customerName': null,
        });
      });
    });

    group('UpdateMenuItemAvailabilityAction', () {
      test('has correct actionName', () {
        const action = UpdateMenuItemAvailabilityAction(
          itemId: '101',
          available: false,
        );
        expect(action.actionName, 'updateMenuItemAvailability');
      });

      test('toPayloadMap includes itemId and available', () {
        const action = UpdateMenuItemAvailabilityAction(
          itemId: '101',
          available: true,
        );
        expect(action.toPayloadMap(), {
          'itemId': '101',
          'available': true,
        });
      });
    });
  });
}
