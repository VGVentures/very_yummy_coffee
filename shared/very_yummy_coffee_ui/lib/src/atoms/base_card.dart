import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Predefined padding variants for [BaseCard].
enum BaseCardPadding {
  /// No padding.
  none,

  /// 8px padding.
  small,

  /// 12px padding.
  medium,

  /// 16px padding.
  large,
}

/// {@template base_card}
/// A styled card component with predefined padding variants.
///
/// This component provides a consistent look and feel for cards
/// across the application, using colors and radius from the design system.
///
/// It offers the following padding options:
/// - `BaseCardPadding.none`: No padding.
/// - `BaseCardPadding.small`: 8px padding.
/// - `BaseCardPadding.medium`: 12px padding.
/// - `BaseCardPadding.large`: 16px padding (default).
///
/// Example usage:
///
/// ```dart
/// // A card with default (large) padding.
/// BaseCard(
///   child: Text('This is a card with large padding.'),
/// );
///
/// // A card with small padding.
/// BaseCard(
///   padding: BaseCardPadding.small,
///   child: Text('This is a card with small padding.'),
/// );
///
/// // A card with no padding.
/// BaseCard(
///   padding: BaseCardPadding.none,
///   child: Image.network('...'), // e.g., for an image that fills the card
/// );
/// ```
/// {@endtemplate}
class BaseCard extends StatelessWidget {
  /// {@macro base_card}
  const BaseCard({
    required this.child,
    this.padding = BaseCardPadding.large,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The padding to apply to the card.
  /// Defaults to `BaseCardPadding.large`.
  final BaseCardPadding padding;

  EdgeInsetsGeometry get _getPadding {
    switch (padding) {
      case BaseCardPadding.none:
        return EdgeInsets.zero;
      case BaseCardPadding.small:
        return SharedSpacing.allSm;
      case BaseCardPadding.medium:
        return SharedSpacing.allMd;
      case BaseCardPadding.large:
        return SharedSpacing.allLg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _getPadding,
      decoration: BoxDecoration(
        color: SharedColors.card,
        borderRadius: SharedRadius.largeAll,
        border: Border.all(
          color: SharedColors.border,
        ),
      ),
      child: child,
    );
  }
}
