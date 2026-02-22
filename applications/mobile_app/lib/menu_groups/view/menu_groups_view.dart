import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';
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
                  MenuGroupsStatus.initial ||
                  MenuGroupsStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  MenuGroupsStatus.failure => Center(
                    child: Text(
                      'Something went wrong',
                      style: context.typography.body,
                    ),
                  ),
                  MenuGroupsStatus.success => _MenuGroupList(
                    menuGroups: state.menuGroups,
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
          child: Text(
            'Very Yummy Coffee',
            style: context.typography.headline.copyWith(
              fontSize: 22,
              color: context.colors.primaryForeground,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuGroupList extends StatelessWidget {
  const _MenuGroupList({required this.menuGroups});

  final List<MenuGroup> menuGroups;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(context.spacing.xl),
      itemCount: menuGroups.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.lg),
      itemBuilder: (context, index) => _MenuGroupCard(group: menuGroups[index]),
    );
  }
}

class _MenuGroupCard extends StatelessWidget {
  const _MenuGroupCard({required this.group});

  final MenuGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: context.colors.border),
      ),
      padding: EdgeInsets.all(context.spacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  group.name,
                  style: context.typography.subtitle.copyWith(
                    fontSize: 20,
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Text(
                  group.description,
                  style: context.typography.muted,
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Color(group.color).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(context.radius.medium),
            ),
          ),
        ],
      ),
    );
  }
}
