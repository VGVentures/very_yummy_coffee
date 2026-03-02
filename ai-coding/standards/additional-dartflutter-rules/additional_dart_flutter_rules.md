<!-- Downloaded from: standards/additional_dart_flutter_rules.md -->
<!-- Source: Additional Dart/Flutter Rules -->

## Core Dart and Flutter Standards

### Tool Preferences
- When available, prefer the **Dart MCP Server** tool over the local `dart` CLI
- Use official Dart/Flutter tooling for analysis and formatting

### Dependency Injection
**Primary Method:** Constructor injection
- Enhances testability and clarity
- Makes dependencies explicit
- Facilitates mocking in tests

```dart
// Good
class UserRepository {
  UserRepository(this._apiClient, this._database);

  final ApiClient _apiClient;
  final Database _database;
}

// Avoid
class UserRepository {
  final apiClient = ApiClient(); // Hard to test
  final database = Database();   // Hidden dependencies
}
```

### Code Style
- Follow `very_good_analysis` lint rules
- Use `const` constructors where possible
- Prefer composition over inheritance
- Keep functions small and focused
- Use meaningful variable names

### Performance
- Minimize widget rebuilds with `const` widgets
- Use `ListView.builder` for long lists
- Implement proper asset caching
- Profile before optimizing
- Use `const` constructors liberally

### Accessibility
- Provide semantic labels for all interactive elements
- Support screen readers
- Ensure sufficient color contrast
- Test with accessibility tools
- Support dynamic font sizes
