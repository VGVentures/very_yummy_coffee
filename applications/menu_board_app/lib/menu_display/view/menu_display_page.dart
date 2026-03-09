import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/bloc/menu_display_bloc.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/menu_display_view.dart';
import 'package:very_yummy_coffee_menu_board_app/order_status/order_status.dart';

class MenuDisplayPage extends StatelessWidget {
  const MenuDisplayPage({super.key});

  factory MenuDisplayPage.pageBuilder(
    BuildContext _,
    GoRouterState _,
  ) => const MenuDisplayPage(key: Key('menu_display_page'));

  static const routeName = '/menu-display';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MenuDisplayBloc(
            menuRepository: context.read<MenuRepository>(),
          )..add(const MenuDisplaySubscriptionRequested()),
        ),
        BlocProvider(
          create: (_) => OrderStatusBloc(
            orderRepository: context.read<OrderRepository>(),
          )..add(const OrderStatusSubscriptionRequested()),
        ),
      ],
      child: const MenuDisplayView(),
    );
  }
}
