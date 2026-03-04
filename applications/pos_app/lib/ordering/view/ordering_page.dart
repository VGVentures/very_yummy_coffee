import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_pos_app/ordering/view/ordering_view.dart';

class OrderingPage extends StatelessWidget {
  const OrderingPage({super.key});

  factory OrderingPage.pageBuilder(BuildContext _, GoRouterState _) =>
      const OrderingPage(key: Key('ordering_page'));

  static const routeName = '/ordering';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: OrderingView());
  }
}
