import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kds_app/app/app.dart';
import 'package:very_yummy_coffee_kds_app/kds/kds.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class AppRouter {
  AppRouter({
    required AppBloc appBloc,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    _goRouter = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: ConnectingPage.routeName,
      refreshListenable: GoRouterRefreshStream(appBloc.stream),
      redirect: (context, state) {
        final status = context.read<AppBloc>().state.status;
        final onConnecting = state.uri.path == ConnectingPage.routeName;
        if (status != AppStatus.connected && !onConnecting) {
          return ConnectingPage.routeName;
        }
        if (status == AppStatus.connected && onConnecting) {
          return KdsPage.routeName;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: ConnectingPage.routeName,
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
