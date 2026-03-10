import 'package:test/test.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

void main() {
  group('RpcTopics', () {
    test('menu is "menu"', () {
      expect(RpcTopics.menu, 'menu');
    });

    test('orders is "orders"', () {
      expect(RpcTopics.orders, 'orders');
    });

    test('order returns "order:<id>"', () {
      expect(RpcTopics.order('abc-123'), 'order:abc-123');
    });
  });
}
