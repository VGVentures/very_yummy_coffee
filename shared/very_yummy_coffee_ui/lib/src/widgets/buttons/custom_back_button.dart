import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// {@template custom_back_button}
/// A styled back button following the design system.
///
/// Displays an arrow icon inside a rounded container with a translucent
/// foreground background, suitable for use over colored headers.
///
/// The caller is responsible for providing navigation via [onPressed].
///
/// Example usage:
///
/// ```dart
/// CustomBackButton(onPressed: () => context.pop());
/// ```
/// {@endtemplate}
class CustomBackButton extends StatelessWidget {
  /// {@macro custom_back_button}
  const CustomBackButton({super.key, this.onPressed});

  /// The callback invoked when the button is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: context.iconSize.tapTarget,
        height: context.iconSize.tapTarget,
        decoration: BoxDecoration(
          color: context.colors.primaryForeground.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(context.radius.medium),
        ),
        child: Icon(
          Icons.arrow_back,
          color: context.colors.primaryForeground,
          size: context.iconSize.large,
        ),
      ),
    );
  }
}
