import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/menu_item_card.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/modifier_bottom_sheet.dart';

class MenuItemGrid extends StatelessWidget {
  const MenuItemGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state.status == MenuStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == MenuStatus.failure) {
          return Center(child: Text(l10n.menuError));
        }
        final items = state.visibleItems;
        if (items.isEmpty) {
          return Center(child: Text(l10n.menuEmpty));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return MenuItemCard(
              item: item,
              onAdd: () async {
                final applicable = state.modifierGroups.applicableTo(
                  item.groupId,
                );
                if (applicable.isEmpty) {
                  context.read<MenuBloc>().add(MenuItemAdded(item));
                  return;
                }
                final modifiers = await showModifierBottomSheet(
                  context: context,
                  item: item,
                  modifierGroups: applicable,
                );
                if (modifiers == null || !context.mounted) return;
                context.read<MenuBloc>().add(
                  MenuItemAdded(item, modifiers: modifiers),
                );
              },
            );
          },
        );
      },
    );
  }
}
