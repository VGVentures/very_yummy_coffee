import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// {@template connecting_view}
/// A shared connecting/loading view with an optional message.
///
/// Uses design tokens (spacing, typography, colors) from the theme.
/// When [message] is non-null, it is shown below the spinner and used for
/// semantics; the spinner may expose progress semantics via framework defaults.
/// {@endtemplate}
class ConnectingView extends StatelessWidget {
  /// {@macro connecting_view}
  const ConnectingView({
    super.key,
    this.message,
  });

  /// Optional message shown below the spinner (e.g. "Connecting…").
  /// When null, only the spinner is shown.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final typography = context.typography;
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          SizedBox(height: spacing.lg),
          Semantics(
            label: message,
            child: Text(
              message!,
              style: typography.body.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
