import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kds_app/app/view/view.dart';
import 'package:very_yummy_coffee_kds_app/kds/kds.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class AppRouter {
  AppRouter({
    required AppBloc appBloc,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    _goRouter = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppShellRoutes.connecting,
      refreshListenable: GoRouterRefreshStream(appBloc.stream),
      redirect: (context, state) => redirect(
        context,
        state,
        connectedHomePath: KdsPage.routeName,
      ),
      routes: [
        GoRoute(
          path: AppShellRoutes.connecting,
          pageBuilder: (context, state) => NoTransitionPage(
            child: ConnectingPage.pageBuilder(context, state),
          ),
        ),
        GoRoute(
          path: KdsPage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            child: KdsPage.pageBuilder(context, state),
          ),
        ),
      ],
    );
  }

  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;
}
