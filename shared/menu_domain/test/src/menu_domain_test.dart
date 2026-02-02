// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:menu_domain/menu_domain.dart';

void main() {
  group('MenuDomain', () {
    test('can be instantiated', () {
      expect(MenuDomain(), isNotNull);
    });
  });
}
