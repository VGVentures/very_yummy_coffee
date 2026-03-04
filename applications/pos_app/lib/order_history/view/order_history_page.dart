import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_history/bloc/order_history_bloc.dart';
import 'package:very_yummy_coffee_pos_app/order_history/view/order_history_view.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  factory OrderHistoryPage.pageBuilder(BuildContext _, GoRouterState _) =>
      const OrderHistoryPage(key: Key('order_history_page'));

  static const routeName = '/order-history';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrderHistoryBloc(orderRepository: context.read<OrderRepository>())
            ..add(const OrderHistorySubscriptionRequested()),
      child: const Scaffold(body: OrderHistoryView()),
    );
  }
}
