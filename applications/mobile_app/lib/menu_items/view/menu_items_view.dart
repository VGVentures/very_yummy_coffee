import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_mobile_app/menu_items/menu_items.dart';
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
                  MenuItemsStatus.initial ||
                  MenuItemsStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  MenuItemsStatus.failure => Center(
                    child: Text(
                      context.l10n.errorSomethingWentWrong,
                      style: context.typography.body,
                    ),
                  ),
                  MenuItemsStatus.success => _MenuItemList(
                    menuItems: state.menuItems,
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
              if (group != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        group!.name,
                        style: context.typography.pageTitle.copyWith(
                          color: context.colors.primaryForeground,
                        ),
                      ),
                      SizedBox(height: context.spacing.xxs),
                      Text(
                        group!.description,
                        style: context.typography.body.copyWith(
                          color: context.colors.primaryForeground.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemList extends StatelessWidget {
  const _MenuItemList({required this.menuItems});

  final List<MenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl).add(
        EdgeInsets.only(top: context.spacing.xl, bottom: context.spacing.huge),
      ),
      itemCount: menuItems.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.lg),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return GestureDetector(
          onTap: () => context.go('/home/menu/${item.groupId}/${item.id}'),
          child: _MenuItemCard(item: item),
        );
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: context.colors.border),
      ),
      padding: EdgeInsets.all(context.spacing.xl),
      child: Row(
        children: [
          Container(
            width: context.iconSize.imageThumbnail,
            height: context.iconSize.imageThumbnail,
            decoration: BoxDecoration(
              color: context.colors.imagePlaceholder,
              borderRadius: BorderRadius.circular(context.radius.medium),
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: context.typography.subtitle.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Text(
                  '\$${(item.price / 100).toStringAsFixed(2)}',
                  style: context.typography.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
