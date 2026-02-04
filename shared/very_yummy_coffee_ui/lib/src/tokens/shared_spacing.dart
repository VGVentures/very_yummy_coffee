import 'package:flutter/widgets.dart';

/// Design system spacing tokens for Very Yummy Coffee.
///
/// Provides consistent spacing values throughout the application.
abstract class SharedSpacing {
  /// Extra small spacing: 4px
  static const double xs = 4;

  /// Small spacing: 8px
  static const double sm = 8;

  /// Medium spacing: 12px
  static const double md = 12;

  /// Large spacing: 16px
  static const double lg = 16;

  /// Extra large spacing: 24px
  static const double xl = 24;

  /// Extra extra large spacing: 32px
  static const double xxl = 32;

  // EdgeInsets helpers for common spacing patterns

  /// All sides extra small padding
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// All sides small padding
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// All sides medium padding
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// All sides large padding
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// All sides extra large padding
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// All sides extra extra large padding
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  /// Horizontal small padding
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal medium padding
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal large padding
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Horizontal extra large padding
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  /// Vertical small padding
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Vertical medium padding
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// Vertical large padding
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// Vertical extra large padding
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}
