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
    required this.tapTarget,
    required this.imageThumbnail,
  });

  /// Small icon size.
  final double small;

  /// Medium icon size.
  final double medium;

  /// Large icon size.
  final double large;

  /// Large icon size (selected).
  final double largeSelected;

  /// Minimum tap target size for icon buttons.
  final double tapTarget;

  /// Size for small image thumbnails/placeholders.
  final double imageThumbnail;

  @override
  AppIconSize copyWith({
    double? small,
    double? medium,
    double? large,
    double? largeSelected,
    double? tapTarget,
    double? imageThumbnail,
  }) {
    return AppIconSize(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      largeSelected: largeSelected ?? this.largeSelected,
      tapTarget: tapTarget ?? this.tapTarget,
      imageThumbnail: imageThumbnail ?? this.imageThumbnail,
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
      tapTarget: lerpDouble(tapTarget, other.tapTarget, t) ?? tapTarget,
      imageThumbnail:
          lerpDouble(imageThumbnail, other.imageThumbnail, t) ?? imageThumbnail,
    );
  }
}
