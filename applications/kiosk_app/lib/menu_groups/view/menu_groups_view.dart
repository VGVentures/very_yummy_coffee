import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/widgets/widgets.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuGroupsView extends StatelessWidget {
  const MenuGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KioskHeader(
            title: l10n.kioskBrandName,
            subtitle: l10n.kioskWhatWouldYouLike,
            showCartBadge: true,
          ),
          Expanded(
            child: BlocBuilder<MenuGroupsBloc, MenuGroupsState>(
              builder: (context, state) {
                return switch (state.status) {
                  MenuGroupsStatus.initial || MenuGroupsStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  MenuGroupsStatus.failure => Center(
                    child: Text(
                      l10n.errorSomethingWentWrong,
                      style: context.typography.body,
                    ),
                  ),
                  MenuGroupsStatus.success => MenuGroupRow(
                    groups: state.menuGroups,
                    onGroupTap: (g) => context.go('/home/menu/${g.id}'),
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
