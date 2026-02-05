import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// The visual and semantic variants for a BaseButton.
enum BaseButtonVariant {
  /// Primary button variant with coffee-themed accent color.
  primary,
  /// Secondary button variant with a lighter, complementary color.
  secondary,
  /// Cancel button variant with an outlined style.
  cancel
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

  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: SharedSpacing.lg,
    vertical: SharedSpacing.xl,
  );

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: SharedRadius.mediumAll,
  );

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case BaseButtonVariant.primary:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: SharedColors.primary,
            foregroundColor: SharedColors.primaryForeground,
            shape: _buttonShape,
            padding: _buttonPadding,
            textStyle: SharedTypography.button,
          ),
          child: Text(label),
        );
      case BaseButtonVariant.secondary:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: SharedColors.secondary,
            foregroundColor: SharedColors.foreground,
            shape: _buttonShape,
            padding: _buttonPadding,
            textStyle: SharedTypography.button,
          ),
          child: Text(label),
        );
      case BaseButtonVariant.cancel:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: SharedColors.background,
            foregroundColor: SharedColors.foreground,
            side: const BorderSide(color: SharedColors.border),
            shape: _buttonShape,
            padding: _buttonPadding,
            textStyle: SharedTypography.button,
          ),
          child: Text(label),
        );
    }
  }
}
