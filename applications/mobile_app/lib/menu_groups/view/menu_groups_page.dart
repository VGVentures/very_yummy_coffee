import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';

class MenuGroupsPage extends StatelessWidget {
  const MenuGroupsPage({super.key});

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
