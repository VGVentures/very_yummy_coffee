import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuGroupsView extends StatelessWidget {
  const MenuGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuGroupsBloc, MenuGroupsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              Expanded(
                child: switch (state.status) {
                  MenuGroupsStatus.initial || MenuGroupsStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  MenuGroupsStatus.failure => Center(
                    child: Text(
                      context.l10n.errorSomethingWentWrong,
                      style: context.typography.body,
                    ),
                  ),
                  MenuGroupsStatus.success => MenuGroupList(
                    groups: state.menuGroups,
                    onGroupTap: (g) => context.go('/home/menu/${g.id}'),
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Row(
            children: [
              CustomBackButton(onPressed: () => context.go('/home')),
              SizedBox(width: context.spacing.sm),
              Expanded(
                child: Text(
                  context.l10n.appTitle,
                  style: context.typography.pageTitle.copyWith(
                    color: context.colors.primaryForeground,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/home/menu/cart'),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: context.colors.primaryForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
