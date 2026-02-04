import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_widgetbook/main.directories.g.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() {
  runApp(const WidgetbookApp());
}

/// Widgetbook application entry point.
///
/// This is the main entry point for the Widgetbook application.
/// It is annotated with @widgetbook.App() to be discovered by the
/// widgetbook_generator.
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  /// Creates a new instance of [WidgetbookApp].
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: ThemeData.light()),
            WidgetbookTheme(name: 'Dark', data: ThemeData.dark()),
          ],
        ),
      ],
    );
  }
}
