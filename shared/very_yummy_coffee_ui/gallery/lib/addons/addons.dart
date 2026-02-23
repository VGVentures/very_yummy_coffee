import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook addons used by the gallery.
final addons = <WidgetbookAddon>[
  MaterialThemeAddon(
    themes: [WidgetbookTheme(name: 'Light', data: CoffeeTheme.light)],
  ),
  TextScaleAddon(),
];
