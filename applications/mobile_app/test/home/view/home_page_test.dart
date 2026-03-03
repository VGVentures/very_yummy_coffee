import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/home/home.dart';

import '../../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('HomePage', () {
    testWidgets('renders HomeView', (tester) async {
      final orderRepository = _MockOrderRepository();
      when(
        () => orderRepository.ordersStream,
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpApp(
        const HomePage(),
        orderRepository: orderRepository,
      );

      expect(find.byType(HomeView), findsOneWidget);
    });
  });
}
