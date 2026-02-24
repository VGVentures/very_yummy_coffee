import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_mobile_app/app/app.dart';
import 'package:very_yummy_coffee_mobile_app/app/app_router/go_router_refresh_stream.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';
import 'package:very_yummy_coffee_mobile_app/item_detail/item_detail.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';
import 'package:very_yummy_coffee_mobile_app/menu_items/menu_items.dart';

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
          routes: [
            GoRoute(
              name: CartPage.routeName,
              path: CartPage.routePath,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                    name: CartPage.routeName,
                    child: CartPage.pageBuilder(context, state),
                  ),
            ),
            GoRoute(
              name: MenuItemsPage.routeName,
              path: MenuItemsPage.routePathTemplate,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                    name: MenuItemsPage.routeName,
                    child: MenuItemsPage.pageBuilder(context, state),
                  ),
              routes: [
                GoRoute(
                  name: ItemDetailPage.routeName,
                  path: ItemDetailPage.routePathTemplate,
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                        name: ItemDetailPage.routeName,
                        child: ItemDetailPage.pageBuilder(context, state),
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;
}
