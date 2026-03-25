import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('parseApiPort', () {
    test('empty returns null', () {
      expect(parseApiPort(''), isNull);
    });

    test('whitespace returns null', () {
      expect(parseApiPort('   '), isNull);
    });

    test('parses valid port', () {
      expect(parseApiPort('8080'), 8080);
      expect(parseApiPort('443'), 443);
      expect(parseApiPort('1'), 1);
    });

    test('invalid returns 8080', () {
      expect(parseApiPort('abc'), 8080);
      expect(parseApiPort('12.5'), 8080);
    });

    test('trims before parse', () {
      expect(parseApiPort('  9090  '), 9090);
    });
  });
}
