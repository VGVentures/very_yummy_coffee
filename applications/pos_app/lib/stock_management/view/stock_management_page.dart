import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/stock_management.dart';

class StockManagementPage extends StatelessWidget {
  const StockManagementPage({super.key});

  factory StockManagementPage.pageBuilder(
    BuildContext _,
    GoRouterState _,
  ) => const StockManagementPage(key: Key('stock_management_page'));

  static const routeName = '/stock-management';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockManagementBloc(
        menuRepository: context.read<MenuRepository>(),
      )..add(const StockManagementSubscriptionRequested()),
      child: const Scaffold(body: StockManagementView()),
    );
  }
}
