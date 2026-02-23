import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// App radius design tokens.
class AppRadius extends ThemeExtension<AppRadius> {
  /// {@macro app_radius}
  const AppRadius({
    required this.medium,
    required this.large,
    required this.card,
    required this.pill,
  });

  /// Medium border radius.
  final double medium;

  /// Large border radius.
  final double large;

  /// Card border radius.
  final double card;

  /// Pill border radius.
  final double pill;

  @override
  AppRadius copyWith({
    double? medium,
    double? large,
    double? card,
    double? pill,
  }) {
    return AppRadius(
      medium: medium ?? this.medium,
      large: large ?? this.large,
      card: card ?? this.card,
      pill: pill ?? this.pill,
    );
  }

  @override
  AppRadius lerp(ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) {
      return this;
    }
    return AppRadius(
      medium: lerpDouble(medium, other.medium, t) ?? medium,
      large: lerpDouble(large, other.large, t) ?? large,
      card: lerpDouble(card, other.card, t) ?? card,
      pill: lerpDouble(pill, other.pill, t) ?? pill,
    );
  }
}
