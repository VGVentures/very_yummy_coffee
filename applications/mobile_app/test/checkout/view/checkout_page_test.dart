import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/checkout/checkout.dart';

import '../../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('CheckoutPage', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
      when(() => orderRepository.currentOrderStream).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    testWidgets('renders CheckoutView', (tester) async {
      await tester.pumpApp(
        const CheckoutPage(),
        orderRepository: orderRepository,
      );

      expect(find.byType(CheckoutView), findsOneWidget);
    });
  });
}
