import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/menu_item_card.dart';

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
          itemBuilder: (context, index) => MenuItemCard(item: items[index]),
        );
      },
    );
  }
}
