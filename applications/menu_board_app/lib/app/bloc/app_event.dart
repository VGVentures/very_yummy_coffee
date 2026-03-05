part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

final class AppStarted extends AppEvent {
  const AppStarted();
}
