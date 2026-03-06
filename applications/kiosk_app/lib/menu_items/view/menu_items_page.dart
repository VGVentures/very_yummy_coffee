import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_items/menu_items.dart';

class MenuItemsPage extends StatelessWidget {
  const MenuItemsPage({required this.groupId, super.key});

  factory MenuItemsPage.pageBuilder(
    BuildContext _,
    GoRouterState state,
  ) => MenuItemsPage(
    key: const Key('menu_items_page'),
    groupId: state.pathParameters['groupId']!,
  );

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
      child: MenuItemsView(groupId: groupId),
    );
  }
}
