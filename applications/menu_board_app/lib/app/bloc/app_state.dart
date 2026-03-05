part of 'app_bloc.dart';

enum AppStatus { initial, connected, disconnected }

@MappableClass()
final class AppState with AppStateMappable {
  const AppState({this.status = AppStatus.initial});

  final AppStatus status;
}
