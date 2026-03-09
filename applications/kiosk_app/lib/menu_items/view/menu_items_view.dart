import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_items/menu_items.dart';
import 'package:very_yummy_coffee_kiosk_app/widgets/widgets.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuItemsView extends StatelessWidget {
  const MenuItemsView({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocSelector<MenuItemsBloc, MenuItemsState, String>(
            selector: (state) => state.groupName,
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
                  MenuItemsStatus.success => _ItemGrid(
                    items: state.menuItems,
                    groupId: groupId,
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

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({required this.items, required this.groupId});

  final List<MenuItem> items;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return GridView.builder(
      padding: EdgeInsets.all(spacing.xxl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: spacing.xl,
        crossAxisSpacing: spacing.xl,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) => _ItemCard(
        item: items[index],
        groupId: groupId,
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.groupId});

  final MenuItem item;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final isAvailable = item.available;

    return GestureDetector(
      onTap: () => context.go('/home/menu/$groupId/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(radius.card),
          border: Border.all(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: UnavailableOverlay(
          isUnavailable: !isAvailable,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.imagePlaceholder,
                        colors.imagePlaceholder.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_cafe_outlined,
                      size: 48,
                      color: colors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: typography.subtitle.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      '\$${(item.price / 100).toStringAsFixed(2)}',
                      style: typography.body.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
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
