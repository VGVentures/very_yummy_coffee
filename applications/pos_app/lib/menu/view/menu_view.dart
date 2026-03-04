import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/menu_category_tabs.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/menu_item_grid.dart';

/// Menu feature panel.
///
/// Provides [MenuBloc] scoped to this widget subtree and renders
/// the category tabs and item grid.
class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuBloc(
        menuRepository: context.read<MenuRepository>(),
        orderRepository: context.read<OrderRepository>(),
      )..add(const MenuSubscriptionRequested()),
      child: const Column(
        children: [
          MenuCategoryTabs(),
          Expanded(child: MenuItemGrid()),
        ],
      ),
    );
  }
}
