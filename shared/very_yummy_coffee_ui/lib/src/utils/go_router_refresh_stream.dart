import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that listens to a [Stream] and notifies listeners
/// whenever the stream emits a new value.
///
/// Designed for use as a router refresh listenable to trigger router
/// re-evaluation when app state changes.
class GoRouterRefreshStream<T> extends ValueNotifier<T?> {
  /// Creates a [GoRouterRefreshStream] that listens to [stream].
  GoRouterRefreshStream(Stream<T> stream) : super(null) {
    _subscription = stream.listen((value) {
      this.value = value;
    });
  }

  late final StreamSubscription<T> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
