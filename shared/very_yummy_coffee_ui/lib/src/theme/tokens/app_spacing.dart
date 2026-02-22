import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// App spacing design tokens.
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// {@macro app_spacing}
  const AppSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.huge,
  });

  /// Extra extra small spacing.
  final double xxs;

  /// Extra small spacing.
  final double xs;

  /// Small spacing.
  final double sm;

  /// Medium spacing.
  final double md;

  /// Large spacing.
  final double lg;

  /// Extra large spacing.
  final double xl;

  /// Extra extra large spacing.
  final double xxl;

  /// Huge spacing.
  final double huge;

  @override
  AppSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? huge,
  }) {
    return AppSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      huge: huge ?? this.huge,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }
    return AppSpacing(
      xxs: lerpDouble(xxs, other.xxs, t) ?? xxs,
      xs: lerpDouble(xs, other.xs, t) ?? xs,
      sm: lerpDouble(sm, other.sm, t) ?? sm,
      md: lerpDouble(md, other.md, t) ?? md,
      lg: lerpDouble(lg, other.lg, t) ?? lg,
      xl: lerpDouble(xl, other.xl, t) ?? xl,
      xxl: lerpDouble(xxl, other.xxl, t) ?? xxl,
      huge: lerpDouble(huge, other.huge, t) ?? huge,
    );
  }
}
