import 'package:flutter/material.dart';

/// Design system color tokens for Very Yummy Coffee.
///
/// All colors are derived from the design system specification
/// and matched to the logo's warm coffee browns, golden banner accent,
/// and cream backgrounds.
abstract class SharedColors {
  /// Primary brand color - warm coffee brown
  /// #C96B45
  static const Color primary = Color(0xFFC96B45);

  /// Secondary background color - light cream
  /// #F0EFE8
  static const Color secondary = Color(0xFFF0EFE8);

  /// Accent gold color - banner accent
  /// #E7BD5A
  static const Color accentGold = Color(0xFFE7BD5A);

  /// Main background color - warm cream
  /// #F5F2EC
  static const Color background = Color(0xFFF5F2EC);

  /// Card background color - pure white
  /// #FFFFFF
  static const Color card = Color(0xFFFFFFFF);

  /// Primary foreground/text color - dark brown
  /// #4A2A22
  static const Color foreground = Color(0xFF4A2A22);

  /// Foreground color for primary-colored backgrounds
  /// #FFFFFF
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Muted/secondary text color - medium brown
  /// #6B5344
  static const Color mutedForeground = Color(0xFF6B5344);

  /// Border color - light beige
  /// #E0D9D0
  static const Color border = Color(0xFFE0D9D0);

  /// Destructive/error color - muted red
  /// #C4574C
  static const Color destructive = Color(0xFFC4574C);

  /// Success color - muted green
  /// #5A9E6F
  static const Color success = Color(0xFF5A9E6F);

  /// Warning color - golden brown
  /// #D4A354
  static const Color warning = Color(0xFFD4A354);

  /// Navigation bar background color
  /// #4A2A22
  static const Color navBarBackground = Color(0xFF4A2A22);

  /// Navigation bar inactive item color
  /// #B8A99A
  static const Color navBarInactive = Color(0xFFB8A99A);
}
