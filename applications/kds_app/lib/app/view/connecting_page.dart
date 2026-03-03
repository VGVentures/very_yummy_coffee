import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';

class ConnectingPage extends StatelessWidget {
  const ConnectingPage({super.key});

  factory ConnectingPage.pageBuilder(
    BuildContext _,
    GoRouterState _,
  ) => const ConnectingPage(key: Key('connecting_page'));

  static const routeName = '/connecting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(context.l10n.connecting),
          ],
        ),
      ),
    );
  }
}
