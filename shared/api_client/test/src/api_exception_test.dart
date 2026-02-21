import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('ApiException', () {
    const message = 'Not Found';
    const statusCode = 404;
    const path = '/users';
    const method = 'GET';

    test('can be instantiated with all required fields', () {
      const exception = ApiException(
        message: message,
        statusCode: statusCode,
        path: path,
        method: method,
      );
      expect(exception.message, message);
      expect(exception.statusCode, statusCode);
      expect(exception.path, path);
      expect(exception.method, method);
    });

    test('toString returns the correct format', () {
      const exception = ApiException(
        message: message,
        statusCode: statusCode,
        path: path,
        method: method,
      );
      expect(
        exception.toString(),
        equals('$method $path: [$statusCode] $message'),
      );
    });
  });
}
