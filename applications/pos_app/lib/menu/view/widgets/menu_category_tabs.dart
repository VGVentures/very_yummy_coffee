import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';

class MenuCategoryTabs extends StatelessWidget {
  const MenuCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final tabs = [
          _Tab(label: l10n.menuCategoryAll, groupId: null),
          for (final group in state.groups)
            _Tab(label: group.name, groupId: group.id),
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tabs.map((tab) {
              final isSelected = state.selectedGroupId == tab.groupId;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ChoiceChip(
                  label: Text(tab.label),
                  selected: isSelected,
                  onSelected: (_) => context.read<MenuBloc>().add(
                    MenuCategorySelected(tab.groupId),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Tab {
  const _Tab({required this.label, required this.groupId});

  final String label;
  final String? groupId;
}
