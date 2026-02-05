import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/tokens/shared_colors.dart';

/// Design system typography tokens for Very Yummy Coffee.
///
/// All text styles use IBM Plex Sans as the primary font family
/// with system fallbacks for readability and approachability.
abstract class SharedTypography {
  /// Primary font family: IBM Plex Sans
  static const String fontFamily = 'IBM Plex Sans';

  /// Section title style (32px, weight 600)
  /// Used for main page titles
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: SharedColors.foreground,
    height: 1.2,
  );

  /// Headline style (24px, weight 600)
  /// Used for prominent headings
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: SharedColors.foreground,
    height: 1.3,
  );

  /// Subtitle style (18px, weight 600)
  /// Used for section headers
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: SharedColors.foreground,
    height: 1.4,
  );

  /// Body text style (14px, normal)
  /// Used for main content and descriptions
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: SharedColors.foreground,
    height: 1.5,
  );

  /// Muted text style (14px, normal)
  /// Used for secondary information and descriptions
  static const TextStyle muted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: SharedColors.mutedForeground,
    height: 1.5,
  );

  /// Caption style (12px, normal)
  /// Used for small labels and metadata
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: SharedColors.mutedForeground,
    height: 1.4,
  );

  /// Small text style (11px, normal)
  /// Used for very small labels
  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: SharedColors.foreground,
    height: 1.3,
  );

  /// Navigation label style (11px, normal)
  /// Used for inactive navigation items
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: SharedColors.navBarInactive,
    height: 1.2,
  );

  /// Active navigation label style (11px, weight 600)
  /// Used for active navigation items
  static const TextStyle navLabelActive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: SharedColors.accentGold,
    height: 1.2,
  );

  /// Button text style (14px, weight 500)
  /// Used for button labels
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
  );
}
