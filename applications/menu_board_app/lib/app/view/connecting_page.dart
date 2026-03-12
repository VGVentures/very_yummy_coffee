import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_menu_board_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class ConnectingPage extends StatelessWidget {
  const ConnectingPage({super.key});

  factory ConnectingPage.pageBuilder(
    BuildContext _,
    GoRouterState _,
  ) => const ConnectingPage(key: Key('connecting_page'));

  static const String routeName = AppShellRoutes.connecting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConnectingView(message: context.l10n.connecting),
      ),
    );
  }
}
