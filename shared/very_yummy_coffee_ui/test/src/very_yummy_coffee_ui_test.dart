import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  group('CoffeeTheme', () {
    test('light theme can be created', () {
      expect(CoffeeTheme.light, isNotNull);
    });

    group('font family', () {
      // Fonts declared in this package's pubspec are registered for apps
      // under this name. The bare family name does not resolve and falls
      // back to the platform's default font without any error.
      const packagedFamily = 'packages/very_yummy_coffee_ui/IBM Plex Sans';

      test('is the packaged family for Material text styles', () {
        final textTheme = CoffeeTheme.light.textTheme;

        expect(textTheme.bodyMedium?.fontFamily, packagedFamily);
        expect(textTheme.titleLarge?.fontFamily, packagedFamily);
        expect(textTheme.labelLarge?.fontFamily, packagedFamily);
      });

      test('is the packaged family for every typography token', () {
        final typography = CoffeeTheme.light.extension<AppTypography>()!;
        final styles = <String, TextStyle>{
          'sectionTitle': typography.sectionTitle,
          'pageTitle': typography.pageTitle,
          'headline': typography.headline,
          'subtitle': typography.subtitle,
          'label': typography.label,
          'body': typography.body,
          'muted': typography.muted,
          'caption': typography.caption,
          'small': typography.small,
          'navLabel': typography.navLabel,
          'navLabelActive': typography.navLabelActive,
          'button': typography.button,
        };

        for (final MapEntry(key: name, value: style) in styles.entries) {
          expect(style.fontFamily, packagedFamily, reason: name);
        }
      });
    });
  });
}
