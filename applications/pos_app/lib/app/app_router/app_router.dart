import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_pos_app/app/app.dart';
import 'package:very_yummy_coffee_pos_app/order_complete/order_complete.dart';
import 'package:very_yummy_coffee_pos_app/order_history/order_history.dart';
import 'package:very_yummy_coffee_pos_app/ordering/ordering.dart';
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
        final path = state.uri.path;
        final onConnecting = path == ConnectingPage.routeName;
        final onComplete = path.startsWith('/order-complete/');

        if (status != AppStatus.connected && !onConnecting) {
          if (onComplete) return null;
          return ConnectingPage.routeName;
        }
        if (status == AppStatus.connected && onConnecting) {
          return OrderingPage.routeName;
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
          path: OrderingPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: OrderingPage.pageBuilder(context, state)),
        ),
        GoRoute(
          path: OrderCompletePage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            child: OrderCompletePage.pageBuilder(context, state),
          ),
        ),
        GoRoute(
          path: OrderHistoryPage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            child: OrderHistoryPage.pageBuilder(context, state),
          ),
        ),
      ],
    );
  }

  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;
}
