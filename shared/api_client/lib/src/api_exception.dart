/// {@template api_exception}
/// An exception that occurs when an API request fails.
/// {@endtemplate}
class ApiException implements Exception {
  /// {@macro api_exception}
  const ApiException({
    required this.message,
    required this.statusCode,
    required this.path,
    required this.method,
  });

  /// The message of the exception.
  final String message;

  /// The status code of the exception.
  final int statusCode;

  /// The error code of the exception.
  final String path;

  /// The method of the exception.
  final String method;

  @override
  String toString() {
    return '$method $path: [$statusCode] $message';
  }
}
