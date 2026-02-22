import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_mobile_app/app/app.dart';
import 'package:very_yummy_coffee_mobile_app/app/app_router/go_router_refresh_stream.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';

class AppRouter {
  AppRouter({
    required AppBloc appBloc,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    _goRouter = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: ConnectingPage.routeName,
      refreshListenable: GoRouterRefreshStream(appBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final status = context.read<AppBloc>().state.status;
        final onConnecting = state.uri.path == ConnectingPage.routeName;
        if (status != AppStatus.connected && !onConnecting) {
          return ConnectingPage.routeName;
        }
        if (status == AppStatus.connected && onConnecting) {
          return MenuGroupsPage.routeName;
        }
        return null;
      },
      routes: [
        GoRoute(
          name: ConnectingPage.routeName,
          path: ConnectingPage.routeName,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage(
                name: ConnectingPage.routeName,
                child: ConnectingPage.pageBuilder(context, state),
              ),
        ),
        GoRoute(
          name: MenuGroupsPage.routeName,
          path: MenuGroupsPage.routeName,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage(
                name: MenuGroupsPage.routeName,
                child: MenuGroupsPage.pageBuilder(context, state),
              ),
        ),
      ],
    );
  }

  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;
}
