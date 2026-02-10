import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// The visual and semantic variants for a BaseButton.
enum BaseButtonVariant {
  /// Primary button variant with coffee-themed accent color.
  primary,

  /// Secondary button variant with a lighter, complementary color.
  secondary,

  /// Cancel button variant with an outlined style.
  cancel,
}

/// {@template base_button}
/// A styled button component with predefined variants.
///
/// This component provides a consistent look and feel for buttons
/// across the application, using colors, radius, and typography from the
/// design system.
///
/// It offers the following variants:
/// - `BaseButtonVariant.primary`: A filled button with the primary color.
/// - `BaseButtonVariant.secondary`: A filled button with the secondary color.
/// - `BaseButtonVariant.cancel`: An outlined button.
///
/// Example usage:
///
/// ```dart
/// // A primary button.
/// BaseButton(
///   onPressed: () {},
///   label: 'Primary Button',
/// );
///
/// // A secondary button.
/// BaseButton(
///   onPressed: () {},
///   label: 'Secondary Button',
///   variant: BaseButtonVariant.secondary,
/// );
///
/// // A cancel button.
/// BaseButton(
///   onPressed: () {},
///   label: 'Cancel',
///   variant: BaseButtonVariant.cancel,
/// );
/// ```
/// {@endtemplate}
class BaseButton extends StatelessWidget {
  /// {@macro base_button}
  const BaseButton({
    required this.onPressed,
    required this.label,
    this.variant = BaseButtonVariant.primary,
    super.key,
  });

  /// The callback that is called when the button is tapped.
  final VoidCallback? onPressed;

  /// The text to display on the button.
  final String label;

  /// The variant of the button.
  final BaseButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final buttonPadding = EdgeInsets.symmetric(
      horizontal: spacing.lg,
      vertical: spacing.xl,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius.medium)),
    );

    switch (variant) {
      case BaseButtonVariant.primary:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.primaryForeground,
            shape: buttonShape,
            padding: buttonPadding,
            textStyle: typography.button,
          ),
          child: Text(label),
        );
      case BaseButtonVariant.secondary:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: colors.secondary,
            foregroundColor: colors.foreground,
            shape: buttonShape,
            padding: buttonPadding,
            textStyle: typography.button,
          ),
          child: Text(label),
        );
      case BaseButtonVariant.cancel:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: colors.background,
            foregroundColor: colors.foreground,
            side: BorderSide(color: colors.border),
            shape: buttonShape,
            padding: buttonPadding,
            textStyle: typography.button,
          ),
          child: Text(label),
        );
    }
  }
}
