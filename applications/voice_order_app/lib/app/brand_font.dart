import 'package:flutter/services.dart';

/// Registers IBM Plex Sans under the family name the shared theme asks for.
///
/// `very_yummy_coffee_ui` declares the font in its own pubspec, which
/// registers it as `packages/very_yummy_coffee_ui/IBM Plex Sans`, while
/// `CoffeeTheme` asks for plain `IBM Plex Sans`. Without this the theme
/// silently falls back to the platform's default font.
Future<void> loadBrandFont() async {
  const fonts = 'packages/very_yummy_coffee_ui/assets/fonts';
  final loader = FontLoader('IBM Plex Sans');
  for (final weight in ['Light', 'Regular', 'Italic', 'Medium', 'Bold']) {
    loader.addFont(rootBundle.load('$fonts/IBMPlexSans-$weight.ttf'));
  }
  await loader.load();
}
