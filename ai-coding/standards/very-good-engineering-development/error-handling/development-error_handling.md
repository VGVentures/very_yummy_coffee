<!-- Downloaded from: https://engineering.verygood.ventures/development/error_handling/llms.txt -->
<!-- Source: Error handling -->

# Error handling

## Document when a call may throw

Document exceptions associated with calling a function in its documentation comments to help understand when an exception might be thrown.

Properly documenting possible exceptions allows developers to handle exceptions, leading to more robust and error-resistant code and reducing the likelihood of unintended errors.

Good ✅:
```dart
/// Permanently deletes an account with the given [name].
///
/// Throws:
///
/// * [UnauthorizedException] if the active role is not [Role.admin], since only
///  admins are authorized to delete accounts.
void deleteAccount(String name) {
  if (activeRole != Role.admin) {
    throw UnauthorizedException('Only admin can delete account');
  }
  // ...
}
```

Bad ❗️:
```dart
/// Permanently deletes an account with the given [name].
void deleteAccount(String name) {
  if (activeRole != Role.admin) {
    throw UnauthorizedException('Only admin can delete account');
  }
  // ...
}
```

## Define descriptive exceptions

Implement `Exception` with descriptive names rather than simply throwing a generic `Exception`.

By creating custom exceptions, developers can provide more meaningful error messages and handle different error types in a more granular way. This enhances code readability and maintainability, as it becomes clear what type of error is being dealt with.

Good ✅:
```dart
class UnauthorizedException implements Exception {
  UnauthorizedException(this.message);

  final String message;

  \@override
  String toString() => 'UnauthorizedException: $message';
}

void deleteAccount(String name) {
  if (activeRole != Role.admin) {
    throw UnauthorizedException('Only admin can delete account');
  }
  // ...
}

void main() {
  try {
    deleteAccount('user');
  } on UnauthorizedException catch (e) {
    // Handle the exception.
  }
}
```

Bad ❗️:
```dart
void deleteAccount(String name) {
  if (activeRole != Role.admin) {
    throw Exception('Only admin can delete account');
  }
  // ...
}

void main() {
  try {
    deleteAccount('user');
  } on Exception catch (e) {
    // Exception is a marker interface implemented by all core library exceptions.
    // It is very generic, potentially catching many different types of exceptions,
    // lacking intent, and making the code harder to understand.
  }
}
```