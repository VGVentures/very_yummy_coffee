import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuItemsView extends StatelessWidget {
  const MenuItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuItemsBloc, MenuItemsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(group: state.group),
              Expanded(
                child: switch (state.status) {
                  MenuItemsStatus.initial || MenuItemsStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  MenuItemsStatus.failure => Center(
                    child: Text(
                      context.l10n.errorSomethingWentWrong,
                      style: context.typography.body,
                    ),
                  ),
                  MenuItemsStatus.success => MenuItemList(
                    items: state.menuItems,
                    onItemTap: (i) =>
                        context.go('/home/menu/${i.groupId}/${i.id}'),
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
  const _Header({required this.group});

  final MenuGroup? group;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: context.spacing.xl,
            top: context.spacing.xl,
            right: context.iconSize.tapTarget + context.spacing.lg,
            bottom: context.spacing.xl,
          ),
          child: Row(
            children: [
              CustomBackButton(onPressed: () => context.pop()),
              SizedBox(width: context.spacing.md),
              Builder(
                builder: (context) {
                  final g = group;
                  if (g == null) return const SizedBox.shrink();
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          g.name,
                          style: context.typography.pageTitle.copyWith(
                            color: context.colors.primaryForeground,
                          ),
                        ),
                        SizedBox(height: context.spacing.xxs),
                        Text(
                          g.description,
                          style: context.typography.body.copyWith(
                            color: context.colors.primaryForeground.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
