part of 'app_bloc.dart';

/// Connection status for the app shell.
enum AppStatus {
  /// Not yet subscribed to connection stream.
  initial,

  /// Backend is connected.
  connected,

  /// Backend is disconnected.
  disconnected,
}

/// Immutable state for the app shell bloc.
@immutable
final class AppState {
  /// Creates an [AppState] with the given [status].
  const AppState({this.status = AppStatus.initial});

  /// Current connection status.
  final AppStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;
}
