import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_pos_app/app/view/view.dart';
import 'package:very_yummy_coffee_pos_app/order_complete/order_complete.dart';
import 'package:very_yummy_coffee_pos_app/order_history/order_history.dart';
import 'package:very_yummy_coffee_pos_app/ordering/ordering.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/stock_management.dart';
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
        connectedHomePath: OrderingPage.routeName,
        allowedWhenDisconnected: const ['/order-complete/'],
      ),
      routes: [
        GoRoute(
          path: AppShellRoutes.connecting,
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
        GoRoute(
          path: StockManagementPage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            child: StockManagementPage.pageBuilder(context, state),
          ),
        ),
      ],
    );
  }

  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;
}
