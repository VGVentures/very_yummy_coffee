import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/order_complete/order_complete.dart';

class OrderCompletePage extends StatelessWidget {
  const OrderCompletePage({required this.orderId, super.key});

  factory OrderCompletePage.pageBuilder(BuildContext _, GoRouterState state) {
    final orderId = state.pathParameters['orderId']!;
    return OrderCompletePage(
      key: const Key('order_complete_page'),
      orderId: orderId,
    );
  }

  static const routeName = 'order_complete';
  static const routePathTemplate = 'confirmation/:orderId';

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderCompleteBloc(
        orderRepository: context.read<OrderRepository>(),
      )..add(OrderCompleteSubscriptionRequested(orderId: orderId)),
      child: const OrderCompleteView(),
    );
  }
}
