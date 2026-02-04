import 'package:flutter/widgets.dart';

/// Design system border radius tokens for Very Yummy Coffee.
///
/// Provides softer, friendlier border radius values for UI elements.
abstract class SharedRadius {
  /// Medium border radius: 14px
  /// Used for buttons and smaller UI elements
  static const double medium = 14;

  /// Large border radius: 18px
  /// Used for cards and larger containers
  static const double large = 18;

  /// Card border radius: 20px
  /// Used specifically for card components
  static const double card = 20;

  /// Pill border radius: 9999px
  /// Creates fully rounded ends
  static const double pill = 9999;

  // BorderRadius helpers for common patterns

  /// Medium border radius for all corners
  static const BorderRadius mediumAll = BorderRadius.all(
    Radius.circular(medium),
  );

  /// Large border radius for all corners
  static const BorderRadius largeAll = BorderRadius.all(
    Radius.circular(large),
  );

  /// Card border radius for all corners
  static const BorderRadius cardAll = BorderRadius.all(
    Radius.circular(card),
  );

  /// Pill border radius for all corners
  static const BorderRadius pillAll = BorderRadius.all(
    Radius.circular(pill),
  );

  /// Medium border radius for top corners only
  static const BorderRadius mediumTop = BorderRadius.only(
    topLeft: Radius.circular(medium),
    topRight: Radius.circular(medium),
  );

  /// Large border radius for top corners only
  static const BorderRadius largeTop = BorderRadius.only(
    topLeft: Radius.circular(large),
    topRight: Radius.circular(large),
  );

  /// Medium border radius for bottom corners only
  static const BorderRadius mediumBottom = BorderRadius.only(
    bottomLeft: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );

  /// Large border radius for bottom corners only
  static const BorderRadius largeBottom = BorderRadius.only(
    bottomLeft: Radius.circular(large),
    bottomRight: Radius.circular(large),
  );
}
