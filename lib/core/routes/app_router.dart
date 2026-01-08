import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_route_paths.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutePaths.root,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(
            child: Text('Hello World!'),
          ),
        );
      },
    ),
  ],
);