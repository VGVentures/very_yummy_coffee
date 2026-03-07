import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// Data for a single modifier option displayed in a [ModifierGroupSelector].
class ModifierOptionData {
  /// Creates a [ModifierOptionData].
  const ModifierOptionData({
    required this.name,
    this.priceDeltaCents = 0,
    this.isSelected = false,
  });

  /// Display name of the option.
  final String name;

  /// Price adjustment in cents. Shown as "+$X.XX" when > 0.
  final int priceDeltaCents;

  /// Whether this option is currently selected.
  final bool isSelected;
}

/// {@template modifier_group_selector}
/// An interactive selector for a group of modifier options.
///
/// Renders a label row with the group name and an optional "(required)"
/// badge, followed by a wrapped row of selectable chips.
///
/// For single-select groups, tapping a new chip deselects the previous.
/// For multi-select groups, tapping toggles individual chips.
/// {@endtemplate}
class ModifierGroupSelector extends StatelessWidget {
  /// {@macro modifier_group_selector}
  const ModifierGroupSelector({
    required this.groupName,
    required this.options,
    required this.onOptionToggled,
    this.isRequired = false,
    this.isMultiSelect = false,
    super.key,
  });

  /// The display name of the modifier group (e.g. "Size", "Milk").
  final String groupName;

  /// Whether this group requires at least one selection.
  final bool isRequired;

  /// Whether multiple options can be selected simultaneously.
  final bool isMultiSelect;

  /// The available options with their selection state.
  final List<ModifierOptionData> options;

  /// Called with the option index when a chip is tapped.
  final ValueChanged<int> onOptionToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              groupName,
              style: context.typography.subtitle.copyWith(
                color: context.colors.foreground,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: context.spacing.sm),
              Text(
                '(required)',
                style: context.typography.small.copyWith(
                  color: context.colors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: context.spacing.sm),
        Wrap(
          spacing: context.spacing.sm,
          runSpacing: context.spacing.sm,
          children: [
            for (var i = 0; i < options.length; i++)
              _OptionChip(
                option: options[i],
                onTap: () => onOptionToggled(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.option,
    required this.onTap,
  });

  final ModifierOptionData option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = option.isSelected;
    final priceLabel = (option.priceDeltaCents / 100).toStringAsFixed(2);
    final label = option.priceDeltaCents > 0
        ? '${option.name} +\$$priceLabel'
        : option.name;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.lg,
          vertical: context.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.card,
          borderRadius: BorderRadius.circular(context.radius.pill),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.border,
          ),
        ),
        child: Text(
          label,
          style: context.typography.body.copyWith(
            color: isSelected
                ? context.colors.primaryForeground
                : context.colors.foreground,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
