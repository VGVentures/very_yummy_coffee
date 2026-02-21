import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  group('MenuRepository', () {
    test('can be instantiated', () {
      expect(MenuRepository(apiClient: _MockApiClient()), isNotNull);
    });
  });
}
