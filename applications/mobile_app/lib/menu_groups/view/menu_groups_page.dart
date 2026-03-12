import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/view/view.dart';

class MenuGroupsPage extends StatelessWidget {
  const MenuGroupsPage({super.key});

  factory MenuGroupsPage.pageBuilder(
    BuildContext context,
    GoRouterState state,
  ) => MenuGroupsPage(key: Key('menu_groups_${context.hashCode}_${state.uri}'));

  static const routeName = '/home/menu';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuGroupsBloc(
        menuRepository: context.read<MenuRepository>(),
      )..add(const MenuGroupsSubscriptionRequested()),
      child: const MenuGroupsView(),
    );
  }
}
