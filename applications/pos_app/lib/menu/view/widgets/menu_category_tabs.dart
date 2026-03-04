import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuCategoryTabs extends StatelessWidget {
  const MenuCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final tabs = [
          _Tab(label: l10n.menuCategoryAll, groupId: null),
          for (final group in state.groups)
            _Tab(label: group.name, groupId: group.id),
        ];
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: tabs.map((tab) {
              final isSelected = state.selectedGroupId == tab.groupId;
              return _CategoryTab(
                label: tab.label,
                isSelected: isSelected,
                onTap: () => context.read<MenuBloc>().add(
                  MenuCategorySelected(tab.groupId),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final colors = context.colors;
    final textColor = isSelected
        ? colors.primaryForeground
        : theme.colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: bgColor,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.label, required this.groupId});

  final String label;
  final String? groupId;
}
