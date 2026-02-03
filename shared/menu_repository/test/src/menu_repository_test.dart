// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';

void main() {
  group('MenuRepository', () {
    test('can be instantiated', () {
      expect(MenuRepository(), isNotNull);
    });
  });
}
