import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';

class MenuGroupsView extends StatelessWidget {
  const MenuGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuGroupsBloc, MenuGroupsState>(
      builder: (context, state) {
        // TODO(dev): return correct widget based on the state.
        return const SizedBox();
      },
    );
  }
}
