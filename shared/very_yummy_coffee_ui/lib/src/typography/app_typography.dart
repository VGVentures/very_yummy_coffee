import 'package:flutter/material.dart';

/// App typography design tokens.
class AppTypography extends ThemeExtension<AppTypography> {
  /// {@macro app_typography}
  const AppTypography({
    required this.sectionTitle,
    required this.pageTitle,
    required this.headline,
    required this.subtitle,
    required this.body,
    required this.muted,
    required this.caption,
    required this.small,
    required this.navLabel,
    required this.navLabelActive,
    required this.button,
  });

  /// Section title style.
  final TextStyle sectionTitle;

  /// Page title style (22px, used in screen headers).
  final TextStyle pageTitle;

  /// Headline style.
  final TextStyle headline;

  /// Subtitle style.
  final TextStyle subtitle;

  /// Body text style.
  final TextStyle body;

  /// Muted text style.
  final TextStyle muted;

  /// Caption text style.
  final TextStyle caption;

  /// Small text style.
  final TextStyle small;

  /// Navigation label style.
  final TextStyle navLabel;

  /// Active navigation label style.
  final TextStyle navLabelActive;

  /// Button text style.
  final TextStyle button;

  @override
  AppTypography copyWith({
    TextStyle? sectionTitle,
    TextStyle? pageTitle,
    TextStyle? headline,
    TextStyle? subtitle,
    TextStyle? body,
    TextStyle? muted,
    TextStyle? caption,
    TextStyle? small,
    TextStyle? navLabel,
    TextStyle? navLabelActive,
    TextStyle? button,
  }) {
    return AppTypography(
      sectionTitle: sectionTitle ?? this.sectionTitle,
      pageTitle: pageTitle ?? this.pageTitle,
      headline: headline ?? this.headline,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      muted: muted ?? this.muted,
      caption: caption ?? this.caption,
      small: small ?? this.small,
      navLabel: navLabel ?? this.navLabel,
      navLabelActive: navLabelActive ?? this.navLabelActive,
      button: button ?? this.button,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) {
      return this;
    }

    return AppTypography(
      sectionTitle:
          TextStyle.lerp(sectionTitle, other.sectionTitle, t) ?? sectionTitle,
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t) ?? pageTitle,
      headline: TextStyle.lerp(headline, other.headline, t) ?? headline,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t) ?? subtitle,
      body: TextStyle.lerp(body, other.body, t) ?? body,
      muted: TextStyle.lerp(muted, other.muted, t) ?? muted,
      caption: TextStyle.lerp(caption, other.caption, t) ?? caption,
      small: TextStyle.lerp(small, other.small, t) ?? small,
      navLabel: TextStyle.lerp(navLabel, other.navLabel, t) ?? navLabel,
      navLabelActive:
          TextStyle.lerp(navLabelActive, other.navLabelActive, t) ??
          navLabelActive,
      button: TextStyle.lerp(button, other.button, t) ?? button,
    );
  }
}
