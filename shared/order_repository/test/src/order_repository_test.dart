import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:test/test.dart';

class _MockWsRpcClient extends Mock implements WsRpcClient {}

void main() {
  group('OrderRepository', () {
    late WsRpcClient wsRpcClient;
    late OrderRepository orderRepository;

    setUp(() {
      wsRpcClient = _MockWsRpcClient();
      when(() => wsRpcClient.subscribe(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    group('ordersStream', () {
      test('subscribes to orders WS topic on first access', () {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..ordersStream;

        verify(() => wsRpcClient.subscribe('orders')).called(1);
      });

      test('does not re-subscribe on repeated access', () {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..ordersStream
          ..ordersStream;

        verify(() => wsRpcClient.subscribe('orders')).called(1);
      });

      test('emits seeded empty Orders immediately on first listen', () async {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient);
        addTearDown(() async => orderRepository.dispose());

        final emitted = <Orders>[];
        final sub = orderRepository.ordersStream.listen(emitted.add);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(emitted, [const Orders(orders: [])]);
      });

      test('emits parsed Orders when WS payload arrives', () async {
        final controller = StreamController<Map<String, dynamic>>.broadcast();
        when(() => wsRpcClient.subscribe('orders')).thenAnswer(
          (_) => controller.stream,
        );
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient);
        addTearDown(() async {
          await orderRepository.dispose();
          await controller.close();
        });

        final emitted = <Orders>[];
        final sub = orderRepository.ordersStream.listen(emitted.add);

        controller.add({
          'orders': <dynamic>[
            <String, dynamic>{
              'id': 'order-1',
              'items': <dynamic>[],
              'status': 'submitted',
            },
          ],
        });
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(emitted.length, greaterThanOrEqualTo(2));
        expect(emitted.last.orders.length, 1);
        expect(emitted.last.orders.first.id, 'order-1');
        expect(emitted.last.orders.first.status, OrderStatus.submitted);
      });

      test('ignores WS payloads that lack an orders key', () async {
        final controller = StreamController<Map<String, dynamic>>.broadcast();
        when(() => wsRpcClient.subscribe('orders')).thenAnswer(
          (_) => controller.stream,
        );
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient);
        addTearDown(() async {
          await orderRepository.dispose();
          await controller.close();
        });

        final emitted = <Orders>[];
        final sub = orderRepository.ordersStream.listen(emitted.add);

        controller.add({'unexpected': 'data'});
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        // Only the initial seeded empty Orders should be emitted.
        expect(emitted, [const Orders(orders: [])]);
      });

      test('dispose completes without error after subscription', () async {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..ordersStream;

        await orderRepository.dispose();

        verify(() => wsRpcClient.subscribe('orders')).called(1);
      });
    });

    group('startOrder', () {
      test('sends startOrder action with orderId', () {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..startOrder('order-abc');
        verify(
          () => wsRpcClient.sendAction('startOrder', {'orderId': 'order-abc'}),
        ).called(1);
      });
    });

    group('markOrderReady', () {
      test('sends markOrderReady action with orderId', () {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..markOrderReady('order-abc');
        verify(
          () => wsRpcClient.sendAction(
            'markOrderReady',
            {'orderId': 'order-abc'},
          ),
        ).called(1);
      });
    });

    group('markOrderCompleted', () {
      test('sends completeOrder action with orderId', () {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..markOrderCompleted('order-abc');
        verify(
          () => wsRpcClient.sendAction(
            'completeOrder',
            {'orderId': 'order-abc'},
          ),
        ).called(1);
      });
    });

    group('cancelOrder', () {
      test('sends cancelOrder action with orderId', () {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..cancelOrder('order-abc');
        verify(
          () => wsRpcClient.sendAction(
            'cancelOrder',
            {'orderId': 'order-abc'},
          ),
        ).called(1);
      });
    });

    group('addItemToCurrentOrder', () {
      test('auto-creates order when currentOrderId is null', () async {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient);

        await orderRepository.addItemToCurrentOrder(
          itemName: 'Latte',
          itemPrice: 500,
          quantity: 1,
        );

        verify(
          () => wsRpcClient.sendAction('createOrder', any()),
        ).called(1);
        verify(
          () => wsRpcClient.sendAction('addItemToOrder', any()),
        ).called(1);
      });

      test('does not create order when currentOrderId is non-null', () async {
        orderRepository = OrderRepository(
          wsRpcClient: wsRpcClient,
          currentOrderId: 'existing-order',
        );

        await orderRepository.addItemToCurrentOrder(
          itemName: 'Latte',
          itemPrice: 500,
          quantity: 1,
        );

        verifyNever(
          () => wsRpcClient.sendAction('createOrder', any()),
        );
        verify(
          () => wsRpcClient.sendAction('addItemToOrder', any()),
        ).called(1);
      });

      test('sends correct payload', () async {
        orderRepository = OrderRepository(
          wsRpcClient: wsRpcClient,
          currentOrderId: 'order-abc',
        );

        await orderRepository.addItemToCurrentOrder(
          itemName: 'Espresso',
          itemPrice: 300,
          quantity: 2,
          modifiers: const [
            SelectedModifier(
              modifierGroupId: 'mg-milk',
              modifierGroupName: 'Milk',
              options: [
                SelectedOption(
                  id: 'milk-oat',
                  name: 'Oat Milk',
                  priceDeltaCents: 75,
                ),
              ],
            ),
          ],
        );

        final captured =
            verify(
                  () => wsRpcClient.sendAction('addItemToOrder', captureAny()),
                ).captured.single
                as Map<String, dynamic>;

        expect(captured['orderId'], 'order-abc');
        expect(captured['itemName'], 'Espresso');
        expect(captured['itemPrice'], 300);
        expect(captured['modifiers'], isA<List<dynamic>>());
        final firstModifier =
            (captured['modifiers'] as List).first as Map<String, dynamic>;
        expect(firstModifier['modifierGroupId'], 'mg-milk');
        expect(captured['quantity'], 2);
        expect(captured['lineItemId'], isA<String>());
      });

      test('propagates exception when auto-create fails', () async {
        when(
          () => wsRpcClient.sendAction('createOrder', any()),
        ).thenThrow(Exception('network error'));
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient);

        expect(
          () => orderRepository.addItemToCurrentOrder(
            itemName: 'Latte',
            itemPrice: 500,
            quantity: 1,
          ),
          throwsA(isA<Exception>()),
        );

        verifyNever(
          () => wsRpcClient.sendAction('addItemToOrder', any()),
        );
      });
    });

    group('updateNameOnCurrentOrder', () {
      test('is a no-op when currentOrderId is null', () async {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient);

        await orderRepository.updateNameOnCurrentOrder('Marcus');

        verifyNever(
          () => wsRpcClient.sendAction(any(), any()),
        );
      });

      test('sets name on existing current order', () async {
        orderRepository = OrderRepository(
          wsRpcClient: wsRpcClient,
          currentOrderId: 'order-abc',
        );

        await orderRepository.updateNameOnCurrentOrder('Marcus');

        verifyNever(
          () => wsRpcClient.sendAction('createOrder', any()),
        );
        final captured =
            verify(
                  () => wsRpcClient.sendAction(
                    'updateNameOnOrder',
                    captureAny(),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(captured['orderId'], 'order-abc');
        expect(captured['customerName'], 'Marcus');
      });

      test('trims whitespace and sends trimmed name', () async {
        orderRepository = OrderRepository(
          wsRpcClient: wsRpcClient,
          currentOrderId: 'order-abc',
        );

        await orderRepository.updateNameOnCurrentOrder('  Marcus  ');

        final captured =
            verify(
                  () => wsRpcClient.sendAction(
                    'updateNameOnOrder',
                    captureAny(),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(captured['customerName'], 'Marcus');
      });

      test('sends null when name is whitespace-only', () async {
        orderRepository = OrderRepository(
          wsRpcClient: wsRpcClient,
          currentOrderId: 'order-abc',
        );

        await orderRepository.updateNameOnCurrentOrder('   ');

        final captured =
            verify(
                  () => wsRpcClient.sendAction(
                    'updateNameOnOrder',
                    captureAny(),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(captured['customerName'], isNull);
      });
    });

    group('submitCurrentOrder', () {
      test(
        'sends submitOrder action with currentOrderId and clears it',
        () {
          orderRepository = OrderRepository(
            wsRpcClient: wsRpcClient,
            currentOrderId: 'order-abc',
          )..submitCurrentOrder();

          verify(
            () =>
                wsRpcClient.sendAction('submitOrder', {'orderId': 'order-abc'}),
          ).called(1);
          expect(orderRepository.currentOrderId, isNull);
        },
      );

      test('is a no-op when currentOrderId is null', () {
        orderRepository = OrderRepository(wsRpcClient: wsRpcClient)
          ..submitCurrentOrder();

        verifyNever(
          () => wsRpcClient.sendAction(any(), any()),
        );
        expect(orderRepository.currentOrderId, isNull);
      });
    });
  });
}
