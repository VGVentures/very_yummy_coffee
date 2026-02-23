import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  group('CoffeeTheme', () {
    test('light theme can be created', () {
      expect(CoffeeTheme.light, isNotNull);
    });
  });
}
