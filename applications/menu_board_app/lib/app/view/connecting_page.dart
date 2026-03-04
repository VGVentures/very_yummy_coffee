import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

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
            SizedBox(height: context.spacing.lg),
            Text(
              'Connecting...',
              style: context.typography.body.copyWith(
                color: context.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
