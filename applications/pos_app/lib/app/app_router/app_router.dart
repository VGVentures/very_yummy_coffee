import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_pos_app/app/app.dart';
import 'package:very_yummy_coffee_pos_app/pos_order/pos_order.dart';
import 'package:very_yummy_coffee_pos_app/pos_order_complete/pos_order_complete.dart';
import 'package:very_yummy_coffee_pos_app/pos_orders/pos_orders.dart';
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
        final onComplete = path.startsWith('/pos-order-complete/');

        if (status != AppStatus.connected && !onConnecting) {
          if (onComplete) return null;
          return ConnectingPage.routeName;
        }
        if (status == AppStatus.connected && onConnecting) {
          return PosOrderPage.routeName;
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
          path: PosOrderPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: PosOrderPage.pageBuilder(context, state)),
        ),
        GoRoute(
          path: PosOrderCompletePage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            child: PosOrderCompletePage.pageBuilder(context, state),
          ),
        ),
        GoRoute(
          path: PosOrdersPage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            child: PosOrdersPage.pageBuilder(context, state),
          ),
        ),
      ],
    );
  }

  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;
}
