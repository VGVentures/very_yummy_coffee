import 'package:test/test.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

void main() {
  group('MenuGroup', () {
    test('can be instantiated', () {
      expect(
        const MenuGroup(
          id: '1',
          name: 'Main',
          description: 'Sandwiches, wraps & more',
          color: 0xFFF0EFE8,
        ),
        isNotNull,
      );
    });
  });

  group('MenuItem', () {
    test('can be instantiated', () {
      expect(
        const MenuItem(id: '1', name: 'Item 1', price: 100, groupId: '1'),
        isNotNull,
      );
    });
  });
}
