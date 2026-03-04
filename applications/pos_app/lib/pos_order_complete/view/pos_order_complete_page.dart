import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/pos_order_complete/bloc/pos_order_complete_bloc.dart';
import 'package:very_yummy_coffee_pos_app/pos_order_complete/view/pos_order_complete_view.dart';

class PosOrderCompletePage extends StatelessWidget {
  const PosOrderCompletePage({required this.orderId, super.key});

  static Widget pageBuilder(BuildContext _, GoRouterState state) {
    final orderId = state.pathParameters['orderId'];
    if (orderId == null) return const _ErrorPage();
    return PosOrderCompletePage(
      key: const Key('pos_order_complete_page'),
      orderId: orderId,
    );
  }

  static const routeName = '/pos-order-complete/:orderId';

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PosOrderCompleteBloc(orderRepository: context.read<OrderRepository>())
            ..add(PosOrderCompleteSubscriptionRequested(orderId)),
      child: BlocListener<PosOrderCompleteBloc, PosOrderCompleteState>(
        listenWhen: (_, curr) =>
            curr.status == PosOrderCompleteStatus.navigatingAway,
        listener: (context, _) => context.go('/pos-order'),
        child: const Scaffold(body: PosOrderCompleteView()),
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
