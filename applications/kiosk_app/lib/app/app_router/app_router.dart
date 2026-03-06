import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kiosk_app/app/app.dart';
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
      initialLocation: ConnectingPage.routeName,
      refreshListenable: GoRouterRefreshStream(appBloc.stream),
      redirect: (context, state) {
        final status = context.read<AppBloc>().state.status;
        final onConnecting = state.uri.path == ConnectingPage.routeName;
        // Exempt the order complete screen from disconnect redirect
        // so a brief network blip doesn't yank the customer off their
        // confirmation screen.
        final onOrderComplete = state.uri.path.contains('/confirmation/');
        if (status != AppStatus.connected &&
            !onConnecting &&
            !onOrderComplete) {
          return ConnectingPage.routeName;
        }
        if (status == AppStatus.connected && onConnecting) {
          return HomePage.routeName;
        }
        return null;
      },
      routes: [
        GoRoute(
          name: ConnectingPage.routeName,
          path: ConnectingPage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            name: ConnectingPage.routeName,
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
