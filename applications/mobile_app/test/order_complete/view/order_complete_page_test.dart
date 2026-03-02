import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/order_complete/order_complete.dart';

import '../../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderCompletePage', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
      when(() => orderRepository.orderStream(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    testWidgets('renders OrderCompleteView', (tester) async {
      await tester.pumpApp(
        const OrderCompletePage(orderId: 'order-abc-1234'),
        orderRepository: orderRepository,
      );

      expect(find.byType(OrderCompleteView), findsOneWidget);
    });
  });
}
