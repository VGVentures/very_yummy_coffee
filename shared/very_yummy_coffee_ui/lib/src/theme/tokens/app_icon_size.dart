import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// App icon size design tokens.
class AppIconSize extends ThemeExtension<AppIconSize> {
  /// {@macro app_icon_size}
  const AppIconSize({
    required this.small,
    required this.medium,
    required this.large,
    required this.largeSelected,
  });

  /// Small icon size.
  final double small;

  /// Medium icon size.
  final double medium;

  /// Large icon size.
  final double large;

  /// Large icon size (selected).
  final double largeSelected;

  @override
  AppIconSize copyWith({
    double? small,
    double? medium,
    double? large,
    double? largeSelected,
  }) {
    return AppIconSize(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      largeSelected: largeSelected ?? this.largeSelected,
    );
  }

  @override
  AppIconSize lerp(ThemeExtension<AppIconSize>? other, double t) {
    if (other is! AppIconSize) {
      return this;
    }
    return AppIconSize(
      small: lerpDouble(small, other.small, t) ?? small,
      medium: lerpDouble(medium, other.medium, t) ?? medium,
      large: lerpDouble(large, other.large, t) ?? large,
      largeSelected:
          lerpDouble(largeSelected, other.largeSelected, t) ?? largeSelected,
    );
  }
}
