import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:very_yummy_coffee_mobile_app/app/app.dart';

class GoRouterRefreshStream extends ValueNotifier<AppStatus?> {
  GoRouterRefreshStream(Stream<AppState> stream) : super(null) {
    _subscription = stream.listen((state) {
      value = state.status;
    });
  }

  late final StreamSubscription<AppState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
