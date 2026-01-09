import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee/core/core.dart';

void main() {
  test('router should starts at /', () {
    expect(router.routeInformationProvider.value.uri.path, '/');
  });

  test('router should have root route configured', () {
    final routes = router.configuration.routes;

    final rootRoute = routes.whereType<GoRoute>().firstWhere(
      (route) => route.path == AppRoutePaths.root,
    );
    expect(rootRoute.path, AppRoutePaths.root);
  });
}
