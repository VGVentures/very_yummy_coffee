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
    required this.topBarBackground,
    required this.connected,
    required this.unavailableOverlay,
    required this.homeBackgroundOverlay,
    required this.statusWarningBackground,
    required this.statusWarningForeground,
    required this.statusSuccessBackground,
    required this.statusSuccessForeground,
    required this.statusDestructiveBackground,
    required this.statusDestructiveForeground,
    required this.statusNeutralBackground,
    required this.statusNeutralForeground,
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

  /// Background color for the app top bar (espresso dark brown).
  final Color topBarBackground;

  /// Color for the "connected" status indicator dot.
  final Color connected;

  /// Semi-transparent overlay for unavailable menu items.
  final Color unavailableOverlay;

  /// Semi-transparent black overlay for the kiosk home screen background.
  final Color homeBackgroundOverlay;

  /// Background for warning/in-progress status chips.
  final Color statusWarningBackground;

  /// Foreground for warning/in-progress status chips.
  final Color statusWarningForeground;

  /// Background for success/completed status chips.
  final Color statusSuccessBackground;

  /// Foreground for success/completed status chips.
  final Color statusSuccessForeground;

  /// Background for destructive/cancelled status chips.
  final Color statusDestructiveBackground;

  /// Foreground for destructive/cancelled status chips.
  final Color statusDestructiveForeground;

  /// Background for neutral/pending status chips.
  final Color statusNeutralBackground;

  /// Foreground for neutral/pending status chips.
  final Color statusNeutralForeground;

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
    Color? topBarBackground,
    Color? connected,
    Color? unavailableOverlay,
    Color? homeBackgroundOverlay,
    Color? statusWarningBackground,
    Color? statusWarningForeground,
    Color? statusSuccessBackground,
    Color? statusSuccessForeground,
    Color? statusDestructiveBackground,
    Color? statusDestructiveForeground,
    Color? statusNeutralBackground,
    Color? statusNeutralForeground,
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
      topBarBackground: topBarBackground ?? this.topBarBackground,
      connected: connected ?? this.connected,
      unavailableOverlay: unavailableOverlay ?? this.unavailableOverlay,
      homeBackgroundOverlay:
          homeBackgroundOverlay ?? this.homeBackgroundOverlay,
      statusWarningBackground:
          statusWarningBackground ?? this.statusWarningBackground,
      statusWarningForeground:
          statusWarningForeground ?? this.statusWarningForeground,
      statusSuccessBackground:
          statusSuccessBackground ?? this.statusSuccessBackground,
      statusSuccessForeground:
          statusSuccessForeground ?? this.statusSuccessForeground,
      statusDestructiveBackground:
          statusDestructiveBackground ?? this.statusDestructiveBackground,
      statusDestructiveForeground:
          statusDestructiveForeground ?? this.statusDestructiveForeground,
      statusNeutralBackground:
          statusNeutralBackground ?? this.statusNeutralBackground,
      statusNeutralForeground:
          statusNeutralForeground ?? this.statusNeutralForeground,
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
      topBarBackground:
          Color.lerp(topBarBackground, other.topBarBackground, t) ??
          topBarBackground,
      connected: Color.lerp(connected, other.connected, t) ?? connected,
      unavailableOverlay:
          Color.lerp(unavailableOverlay, other.unavailableOverlay, t) ??
          unavailableOverlay,
      homeBackgroundOverlay:
          Color.lerp(
            homeBackgroundOverlay,
            other.homeBackgroundOverlay,
            t,
          ) ??
          homeBackgroundOverlay,
      statusWarningBackground:
          Color.lerp(
            statusWarningBackground,
            other.statusWarningBackground,
            t,
          ) ??
          statusWarningBackground,
      statusWarningForeground:
          Color.lerp(
            statusWarningForeground,
            other.statusWarningForeground,
            t,
          ) ??
          statusWarningForeground,
      statusSuccessBackground:
          Color.lerp(
            statusSuccessBackground,
            other.statusSuccessBackground,
            t,
          ) ??
          statusSuccessBackground,
      statusSuccessForeground:
          Color.lerp(
            statusSuccessForeground,
            other.statusSuccessForeground,
            t,
          ) ??
          statusSuccessForeground,
      statusDestructiveBackground:
          Color.lerp(
            statusDestructiveBackground,
            other.statusDestructiveBackground,
            t,
          ) ??
          statusDestructiveBackground,
      statusDestructiveForeground:
          Color.lerp(
            statusDestructiveForeground,
            other.statusDestructiveForeground,
            t,
          ) ??
          statusDestructiveForeground,
      statusNeutralBackground:
          Color.lerp(
            statusNeutralBackground,
            other.statusNeutralBackground,
            t,
          ) ??
          statusNeutralBackground,
      statusNeutralForeground:
          Color.lerp(
            statusNeutralForeground,
            other.statusNeutralForeground,
            t,
          ) ??
          statusNeutralForeground,
    );
  }
}
