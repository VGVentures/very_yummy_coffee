import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/pos_orders/bloc/pos_orders_bloc.dart';
import 'package:very_yummy_coffee_pos_app/pos_orders/view/pos_orders_view.dart';

class PosOrdersPage extends StatelessWidget {
  const PosOrdersPage({super.key});

  factory PosOrdersPage.pageBuilder(BuildContext _, GoRouterState _) =>
      const PosOrdersPage(key: Key('pos_orders_page'));

  static const routeName = '/pos-orders';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PosOrdersBloc(orderRepository: context.read<OrderRepository>())
            ..add(const PosOrdersSubscriptionRequested()),
      child: const Scaffold(body: PosOrdersView()),
    );
  }
}
