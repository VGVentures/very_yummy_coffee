import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/cart_count/cart_count.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCountBloc(
        orderRepository: context.read<OrderRepository>(),
      )..add(const CartCountSubscriptionRequested()),
      child: const CartBadgeView(),
    );
  }
}
