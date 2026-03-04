import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/order_complete/bloc/order_complete_bloc.dart';
import 'package:very_yummy_coffee_pos_app/order_complete/view/order_complete_view.dart';

class OrderCompletePage extends StatelessWidget {
  const OrderCompletePage({required this.orderId, super.key});

  static Widget pageBuilder(BuildContext _, GoRouterState state) {
    final orderId = state.pathParameters['orderId'];
    if (orderId == null) return const _ErrorPage();
    return OrderCompletePage(
      key: const Key('order_complete_page'),
      orderId: orderId,
    );
  }

  static const routeName = '/order-complete/:orderId';

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrderCompleteBloc(orderRepository: context.read<OrderRepository>())
            ..add(OrderCompleteSubscriptionRequested(orderId)),
      child: BlocListener<OrderCompleteBloc, OrderCompleteState>(
        listenWhen: (_, curr) =>
            curr.status == OrderCompleteStatus.navigatingAway,
        listener: (context, _) => context.go('/ordering'),
        child: const Scaffold(body: OrderCompleteView()),
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Order not found')));
  }
}
