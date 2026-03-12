import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kiosk_app/app/view/view.dart';
import 'package:very_yummy_coffee_kiosk_app/cart/cart.dart';
import 'package:very_yummy_coffee_kiosk_app/checkout/checkout.dart';
import 'package:very_yummy_coffee_kiosk_app/home/home.dart';
import 'package:very_yummy_coffee_kiosk_app/item_detail/item_detail.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_groups/menu_groups.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_items/menu_items.dart';
import 'package:very_yummy_coffee_kiosk_app/order_complete/order_complete.dart';
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
        connectedHomePath: HomePage.routeName,
        allowedWhenDisconnected: const ['/confirmation/'],
      ),
      routes: [
        GoRoute(
          name: AppShellRoutes.connecting,
          path: AppShellRoutes.connecting,
          pageBuilder: (context, state) => NoTransitionPage(
            name: AppShellRoutes.connecting,
            child: ConnectingPage.pageBuilder(context, state),
          ),
        ),
        GoRoute(
          name: HomePage.routeName,
          path: HomePage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            name: HomePage.routeName,
            child: HomePage.pageBuilder(context, state),
          ),
          routes: [
            GoRoute(
              name: MenuGroupsPage.routeName,
              path: 'menu',
              pageBuilder: (context, state) => MaterialPage(
                name: MenuGroupsPage.routeName,
                child: MenuGroupsPage.pageBuilder(context, state),
              ),
              routes: [
                // Cart route MUST be registered before :groupId to prevent
                // /home/menu/cart from matching :groupId="cart".
                GoRoute(
                  name: CartPage.routeName,
                  path: CartPage.routePath,
                  pageBuilder: (context, state) => MaterialPage(
                    name: CartPage.routeName,
                    child: CartPage.pageBuilder(context, state),
                  ),
                  routes: [
                    GoRoute(
                      name: CheckoutPage.routeName,
                      path: CheckoutPage.routePath,
                      pageBuilder: (context, state) => MaterialPage(
                        name: CheckoutPage.routeName,
                        child: CheckoutPage.pageBuilder(context, state),
                      ),
                      routes: [
                        GoRoute(
                          name: OrderCompletePage.routeName,
                          path: OrderCompletePage.routePathTemplate,
                          pageBuilder: (context, state) => MaterialPage(
                            name: OrderCompletePage.routeName,
                            child: OrderCompletePage.pageBuilder(
                              context,
                              state,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  name: MenuItemsPage.routeName,
                  path: MenuItemsPage.routePathTemplate,
                  pageBuilder: (context, state) => MaterialPage(
                    name: MenuItemsPage.routeName,
                    child: MenuItemsPage.pageBuilder(context, state),
                  ),
                  routes: [
                    GoRoute(
                      name: ItemDetailPage.routeName,
                      path: ItemDetailPage.routePathTemplate,
                      pageBuilder: (context, state) => MaterialPage(
                        name: ItemDetailPage.routeName,
                        child: ItemDetailPage.pageBuilder(
                          context,
                          state,
                        ),
                      ),
                    ),
                  ],
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
