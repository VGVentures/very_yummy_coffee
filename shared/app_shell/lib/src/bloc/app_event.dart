part of 'app_bloc.dart';

/// Base class for [AppBloc] events.
sealed class AppEvent {
  const AppEvent();
}

/// Notifies the bloc to start listening to connection status.
final class AppStarted extends AppEvent {
  /// Creates an [AppStarted] event.
  const AppStarted();
}
