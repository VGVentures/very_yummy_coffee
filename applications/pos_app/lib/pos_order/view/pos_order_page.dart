import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/menu/menu.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/order_ticket.dart';
import 'package:very_yummy_coffee_pos_app/pos_order/view/pos_order_view.dart';

class PosOrderPage extends StatelessWidget {
  const PosOrderPage({super.key});

  factory PosOrderPage.pageBuilder(BuildContext _, GoRouterState _) =>
      const PosOrderPage(key: Key('pos_order_page'));

  static const routeName = '/pos-order';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MenuBloc(
            menuRepository: context.read<MenuRepository>(),
            orderRepository: context.read<OrderRepository>(),
          )..add(const MenuSubscriptionRequested()),
        ),
        BlocProvider(
          create: (_) =>
              OrderTicketBloc(orderRepository: context.read<OrderRepository>())
                ..add(const OrderTicketSubscriptionRequested())
                ..add(const OrderTicketCreateOrderRequested()),
        ),
      ],
      child: BlocListener<OrderTicketBloc, OrderTicketState>(
        listenWhen: (prev, curr) =>
            curr.status == OrderTicketStatus.submitted &&
            prev.status != OrderTicketStatus.submitted,
        listener: (context, state) {
          final orderId = state.submittedOrderId!;
          context.go('/pos-order-complete/$orderId');
        },
        child: const Scaffold(body: PosOrderView()),
      ),
    );
  }
}
