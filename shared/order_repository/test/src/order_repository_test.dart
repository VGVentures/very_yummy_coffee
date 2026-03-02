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
