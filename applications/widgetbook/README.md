# Widgetbook for Very Yummy Coffee

This project uses [Widgetbook](https://www.widgetbook.io/) to catalog and test UI components from the `very_yummy_coffee_ui` package and other shared widgets.

## 🚀 Running Widgetbook

To start the Widgetbook application, run:

```bash
flutter run -d macos
```

Or for web:

```bash
flutter run -d chrome
```

## ➕ Adding New Use Cases

We use the `build_runner` and `@widgetbook.UseCase` annotation to automatically generate the Widgetbook structure.

### 1. Create a Use Case

You can define use cases in `lib/components` (for app-local widgets) or directly in the `shared/very_yummy_coffee_ui` package (preferred for reusable components).

**Example:**

```dart
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Primary Button',
  type: ElevatedButton,
)
Widget primaryButtonUseCase(BuildContext context) {
  return ElevatedButton(
    onPressed: () {},
    child: const Text('Primary Action'),
  );
}
```

### 2. Generate Code

After adding the annotation, you must regenerate the `main.directories.g.dart` file:

```bash
# Run this in applications/widgetbook
dart run build_runner build --delete-conflicting-outputs
```

The new component will now appear in the Widgetbook sidebar.

## 🎛️ Using Knobs

You can use "Knobs" to allow users to dynamically adjust properties of your widget from the Widgetbook UI.

**Example:**

```dart
import 'package:widgetbook/widgetbook.dart'; // Import this

@widgetbook.UseCase(name: 'Dynamic Button', type: ElevatedButton)
Widget dynamicButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {},
    child: Text(
      context.knobs.string(
        label: 'Button Label',
        initialValue: 'Click Me',
      ),
    ),
  );
}
```
## 📁 Project Structure

*   `lib/main.dart`: The entry point configuration for Widgetbook.
*   `lib/components/`: Directory for Widgetbook-specific use cases or examples.
*   `../shared/very_yummy_coffee_ui`: The shared UI package being documented.
