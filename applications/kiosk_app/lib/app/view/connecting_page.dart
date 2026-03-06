import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConnectingPage extends StatelessWidget {
  const ConnectingPage({super.key});

  factory ConnectingPage.pageBuilder(
    BuildContext _,
    GoRouterState _,
  ) => const ConnectingPage(key: Key('connecting_page'));

  static const routeName = '/connecting';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
