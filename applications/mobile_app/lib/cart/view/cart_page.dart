import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  factory CartPage.pageBuilder(BuildContext _, GoRouterState _) =>
      const CartPage(key: Key('cart_page'));

  static const routeName = 'cart';
  static const routePath = '/cart';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartBloc(
        orderRepository: context.read<OrderRepository>(),
      )..add(const CartSubscriptionRequested()),
      child: const CartView(),
    );
  }
}
