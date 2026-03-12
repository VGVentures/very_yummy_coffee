import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/widgets/widgets.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuItemsView extends StatelessWidget {
  const MenuItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocSelector<MenuItemsBloc, MenuItemsState, String>(
            selector: (state) => state.group?.name ?? '',
            builder: (context, groupName) => KioskHeader(
              showBackButton: true,
              onBack: () => context.go('/home/menu'),
              title: groupName,
              showCartBadge: true,
            ),
          ),
          Expanded(
            child: BlocBuilder<MenuItemsBloc, MenuItemsState>(
              builder: (context, state) {
                return switch (state.status) {
                  MenuItemsStatus.initial || MenuItemsStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  MenuItemsStatus.failure => Center(
                    child: Text(
                      context.l10n.errorSomethingWentWrong,
                      style: context.typography.body,
                    ),
                  ),
                  MenuItemsStatus.success => MenuItemGrid(
                    items: state.menuItems,
                    onItemTap: (i) =>
                        context.go('/home/menu/${i.groupId}/${i.id}'),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
