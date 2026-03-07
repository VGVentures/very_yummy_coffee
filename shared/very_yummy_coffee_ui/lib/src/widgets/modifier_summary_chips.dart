import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// {@template modifier_summary_chips}
/// A compact horizontal wrap of small, muted chips displaying modifier labels.
///
/// Used in cart line items, order summaries, and KDS cards to show selected
/// modifier options (e.g. "Oat Milk", "Grande", "Vanilla").
/// {@endtemplate}
class ModifierSummaryChips extends StatelessWidget {
  /// {@macro modifier_summary_chips}
  const ModifierSummaryChips({
    required this.labels,
    super.key,
  });

  /// The modifier summary texts to display as chips.
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: context.spacing.xs,
      runSpacing: context.spacing.xs,
      children: [
        for (final label in labels)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.sm,
              vertical: context.spacing.xxs,
            ),
            decoration: BoxDecoration(
              color: context.colors.secondary,
              borderRadius: BorderRadius.circular(context.radius.small),
            ),
            child: Text(
              label,
              style: context.typography.caption.copyWith(
                color: context.colors.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}
