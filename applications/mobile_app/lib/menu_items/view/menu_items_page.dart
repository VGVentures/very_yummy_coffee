import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_mobile_app/menu_items/view/view.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuItemsPage extends StatelessWidget {
  const MenuItemsPage({required this.groupId, super.key});

  /// Builds the page widget. Returns an error placeholder when [groupId] is
  /// missing or empty so the router always receives a valid [Widget].
  static Widget pageBuilder(BuildContext _, GoRouterState state) {
    final groupId = state.pathParameters['groupId'];
    if (groupId == null || groupId.isEmpty) {
      return const _InvalidMenuItemsPlaceholder(
        key: Key('menu_items_invalid'),
      );
    }
    return MenuItemsPage(
      key: const Key('menu_items_page'),
      groupId: groupId,
    );
  }

  static const routePathTemplate = ':groupId';
  static const routeName = 'menu-items';

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuItemsBloc(
        menuRepository: context.read<MenuRepository>(),
        groupId: groupId,
      )..add(const MenuItemsSubscriptionRequested()),
      child: const MenuItemsView(),
    );
  }
}

class _InvalidMenuItemsPlaceholder extends StatelessWidget {
  const _InvalidMenuItemsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.errorSomethingWentWrong,
              style: context.typography.body,
            ),
            SizedBox(height: context.spacing.lg),
            CustomBackButton(onPressed: () => context.go('/home')),
          ],
        ),
      ),
    );
  }
}
