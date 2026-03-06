import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_groups/menu_groups.dart';
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
                  MenuGroupsStatus.success => _CategoryCardRow(
                    groups: state.menuGroups,
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

class _CategoryCardRow extends StatelessWidget {
  const _CategoryCardRow({required this.groups});

  final List<MenuGroup> groups;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.xxl),
      child: Row(
        children: groups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : spacing.md,
                right: index == groups.length - 1 ? 0 : spacing.md,
              ),
              child: _CategoryCard(group: group),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.group});

  final MenuGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final groupColor = Color(group.color);

    return GestureDetector(
      onTap: () => context.go('/home/menu/${group.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(radius.card),
          border: Border.all(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      groupColor.withValues(alpha: 0.3),
                      groupColor.withValues(alpha: 0.15),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.local_cafe_outlined,
                    size: 64,
                    color: groupColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: typography.subtitle.copyWith(
                      color: groupColor,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    group.description,
                    style: typography.muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
