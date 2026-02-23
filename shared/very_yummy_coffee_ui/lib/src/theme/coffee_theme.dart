import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/colors/app_colors.dart';
import 'package:very_yummy_coffee_ui/src/spacing/app_icon_size.dart';
import 'package:very_yummy_coffee_ui/src/spacing/app_radius.dart';
import 'package:very_yummy_coffee_ui/src/spacing/app_spacing.dart';
import 'package:very_yummy_coffee_ui/src/typography/app_typography.dart';

/// The design system theme for Very Yummy Coffee.
abstract class CoffeeTheme {
  /// The light theme data.
  static ThemeData get light {
    const colors = AppColors(
      primary: Color(0xFFC96B45),
      secondary: Color(0xFFF0EFE8),
      accentGold: Color(0xFFE7BD5A),
      background: Color(0xFFF5F2EC),
      card: Color(0xFFFFFFFF),
      foreground: Color(0xFF4A2A22),
      primaryForeground: Color(0xFFFFFFFF),
      mutedForeground: Color(0xFF6B5344),
      border: Color(0xFFE0D9D0),
      destructive: Color(0xFFC4574C),
      success: Color(0xFF5A9E6F),
      warning: Color(0xFFD4A354),
      navBarBackground: Color(0xFF4A2A22),
      navBarInactive: Color(0xFFB8A99A),
      imagePlaceholder: Color(0xFFE8DDD6),
    );

    const typography = AppTypography(
      pageTitle: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A2A22),
        height: 1.3,
      ),
      sectionTitle: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A2A22),
        height: 1.2,
      ),
      headline: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A2A22),
        height: 1.3,
      ),
      subtitle: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A2A22),
        height: 1.4,
      ),
      body: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFF4A2A22),
        height: 1.5,
      ),
      muted: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFF6B5344),
        height: 1.5,
      ),
      caption: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Color(0xFF6B5344),
        height: 1.4,
      ),
      small: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: Color(0xFF4A2A22),
        height: 1.3,
      ),
      navLabel: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: Color(0xFFB8A99A),
        height: 1.2,
      ),
      navLabelActive: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE7BD5A),
        height: 1.2,
      ),
      button: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 14,
        height: 1.2,
      ),
    );

    const spacing = AppSpacing(
      xxs: 2,
      xs: 4,
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
      xxl: 24,
      huge: 32,
    );

    const radius = AppRadius(
      medium: 14,
      large: 18,
      card: 20,
      pill: 9999,
    );

    const iconSize = AppIconSize(
      small: 8,
      medium: 16,
      large: 24,
      largeSelected: 28,
      tapTarget: 40,
      imageThumbnail: 56,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'IBM Plex Sans',
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        surface: colors.background,
      ),
      extensions: const [
        colors,
        typography,
        spacing,
        radius,
        iconSize,
      ],
    );
  }
}

/// Extension methods to access design tokens from the context.
extension CoffeeThemeExtensions on BuildContext {
  /// Returns the [AppColors] extension.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// Returns the [AppTypography] extension.
  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;

  /// Returns the [AppSpacing] extension.
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;

  /// Returns the [AppRadius] extension.
  AppRadius get radius => Theme.of(this).extension<AppRadius>()!;

  /// Returns the [AppIconSize] extension.
  AppIconSize get iconSize => Theme.of(this).extension<AppIconSize>()!;
}
