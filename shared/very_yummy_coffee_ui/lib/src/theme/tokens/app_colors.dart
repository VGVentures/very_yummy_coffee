import 'package:flutter/material.dart';

/// App color design tokens.
class AppColors extends ThemeExtension<AppColors> {
  /// {@macro app_colors}
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accentGold,
    required this.background,
    required this.card,
    required this.foreground,
    required this.primaryForeground,
    required this.mutedForeground,
    required this.border,
    required this.destructive,
    required this.success,
    required this.warning,
    required this.navBarBackground,
    required this.navBarInactive,
    required this.imagePlaceholder,
  });

  /// Primary brand color.
  final Color primary;

  /// Secondary brand color.
  final Color secondary;

  /// Accent gold color.
  final Color accentGold;

  /// Main background color.
  final Color background;

  /// Card background color.
  final Color card;

  /// Main text color.
  final Color foreground;

  /// Text color on primary background.
  final Color primaryForeground;

  /// Muted text color.
  final Color mutedForeground;

  /// Border color.
  final Color border;

  /// Destructive/Error color.
  final Color destructive;

  /// Success color.
  final Color success;

  /// Warning color.
  final Color warning;

  /// Navigation bar background color.
  final Color navBarBackground;

  /// Navigation bar inactive item color.
  final Color navBarInactive;

  /// Background color for image placeholder areas.
  final Color imagePlaceholder;

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accentGold,
    Color? background,
    Color? card,
    Color? foreground,
    Color? primaryForeground,
    Color? mutedForeground,
    Color? border,
    Color? destructive,
    Color? success,
    Color? warning,
    Color? navBarBackground,
    Color? navBarInactive,
    Color? imagePlaceholder,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accentGold: accentGold ?? this.accentGold,
      background: background ?? this.background,
      card: card ?? this.card,
      foreground: foreground ?? this.foreground,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      border: border ?? this.border,
      destructive: destructive ?? this.destructive,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      navBarInactive: navBarInactive ?? this.navBarInactive,
      imagePlaceholder: imagePlaceholder ?? this.imagePlaceholder,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      accentGold: Color.lerp(accentGold, other.accentGold, t) ?? accentGold,
      background: Color.lerp(background, other.background, t) ?? background,
      card: Color.lerp(card, other.card, t) ?? card,
      foreground: Color.lerp(foreground, other.foreground, t) ?? foreground,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t) ??
          primaryForeground,
      mutedForeground:
          Color.lerp(mutedForeground, other.mutedForeground, t) ??
          mutedForeground,
      border: Color.lerp(border, other.border, t) ?? border,
      destructive: Color.lerp(destructive, other.destructive, t) ?? destructive,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      navBarBackground:
          Color.lerp(navBarBackground, other.navBarBackground, t) ??
          navBarBackground,
      navBarInactive:
          Color.lerp(navBarInactive, other.navBarInactive, t) ?? navBarInactive,
      imagePlaceholder:
          Color.lerp(imagePlaceholder, other.imagePlaceholder, t) ??
          imagePlaceholder,
    );
  }
}
