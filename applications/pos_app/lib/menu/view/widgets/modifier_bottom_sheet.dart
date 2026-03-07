import 'package:flutter/material.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Shows a bottom sheet for selecting modifier options for a menu item.
///
/// Returns a [List<SelectedModifier>] when confirmed, or `null` if dismissed.
Future<List<SelectedModifier>?> showModifierBottomSheet({
  required BuildContext context,
  required MenuItem item,
  required List<ModifierGroup> modifierGroups,
}) {
  return showModalBottomSheet<List<SelectedModifier>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ModifierBottomSheetBody(
      item: item,
      modifierGroups: modifierGroups,
    ),
  );
}

class _ModifierBottomSheetBody extends StatefulWidget {
  const _ModifierBottomSheetBody({
    required this.item,
    required this.modifierGroups,
  });

  final MenuItem item;
  final List<ModifierGroup> modifierGroups;

  @override
  State<_ModifierBottomSheetBody> createState() =>
      _ModifierBottomSheetBodyState();
}

class _ModifierBottomSheetBodyState extends State<_ModifierBottomSheetBody> {
  late final Map<String, List<String>> _selections;

  @override
  void initState() {
    super.initState();
    _selections = {
      for (final group in widget.modifierGroups)
        group.id: [
          if (group.defaultOptionId != null) group.defaultOptionId!,
        ],
    };
  }

  bool get _canConfirm {
    for (final group in widget.modifierGroups) {
      if (group.required && (_selections[group.id]?.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  List<SelectedModifier> _buildResult() {
    final result = <SelectedModifier>[];
    for (final group in widget.modifierGroups) {
      final selectedIds = _selections[group.id] ?? [];
      if (selectedIds.isEmpty) continue;
      result.add(
        SelectedModifier(
          modifierGroupId: group.id,
          modifierGroupName: group.name,
          options: [
            for (final optionId in selectedIds)
              () {
                final option = group.options.firstWhere(
                  (o) => o.id == optionId,
                );
                return SelectedOption(
                  id: option.id,
                  name: option.name,
                  priceDeltaCents: option.priceDeltaCents,
                );
              }(),
          ],
        ),
      );
    }
    return result;
  }

  void _onOptionToggled(ModifierGroup group, int optionIndex) {
    final optionId = group.options[optionIndex].id;
    setState(() {
      final current = _selections[group.id] ?? [];
      if (group.selectionMode == SelectionMode.single) {
        _selections[group.id] = [optionId];
      } else {
        if (current.contains(optionId)) {
          _selections[group.id] = current
              .where((id) => id != optionId)
              .toList();
        } else {
          _selections[group.id] = [...current, optionId];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(
        left: spacing.lg,
        top: spacing.lg,
        right: spacing.lg,
        bottom: spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.item.name,
            style: context.typography.subtitle.copyWith(
              color: context.colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.lg),
          for (final group in widget.modifierGroups) ...[
            ModifierGroupSelector(
              groupName: group.name,
              isRequired: group.required,
              isMultiSelect: group.selectionMode == SelectionMode.multi,
              options: [
                for (final option in group.options)
                  ModifierOptionData(
                    name: option.name,
                    priceDeltaCents: option.priceDeltaCents,
                    isSelected:
                        _selections[group.id]?.contains(option.id) ?? false,
                  ),
              ],
              onOptionToggled: (index) => _onOptionToggled(group, index),
            ),
            SizedBox(height: spacing.lg),
          ],
          BaseButton(
            label: context.l10n.modifierSheetConfirm,
            onPressed: _canConfirm
                ? () => Navigator.of(context).pop(_buildResult())
                : null,
          ),
        ],
      ),
    );
  }
}
