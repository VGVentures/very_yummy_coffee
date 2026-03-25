/// Parses the `API_PORT` dart-define string for `ApiClient.fromDartDefines`.
///
/// - Whitespace-only or empty string → `null` (URI uses default port for the
///   scheme).
/// - Valid positive integer string → that port.
/// - Invalid → `8080`.
int? parseApiPort(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final parsed = int.tryParse(trimmed);
  if (parsed == null) return 8080;
  return parsed;
}
