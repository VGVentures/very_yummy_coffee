import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/kds.dart';

class KdsPage extends StatelessWidget {
  const KdsPage({super.key});

  factory KdsPage.pageBuilder(BuildContext _, GoRouterState _) =>
      const KdsPage(key: Key('kds_page'));

  static const routeName = '/kds';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KdsBloc(
        orderRepository: context.read<OrderRepository>(),
      )..add(const KdsSubscriptionRequested()),
      child: const KdsView(),
    );
  }
}
