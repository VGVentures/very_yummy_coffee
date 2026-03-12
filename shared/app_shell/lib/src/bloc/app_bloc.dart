import 'package:bloc/bloc.dart';
import 'package:connection_repository/connection_repository.dart';
import 'package:flutter/foundation.dart';

part 'app_event.dart';
part 'app_state.dart';

/// {@template app_bloc}
/// Bloc that listens to [ConnectionRepository.isConnected] and emits
/// [AppState] with [AppStatus.connected] or [AppStatus.disconnected].
/// {@endtemplate}
class AppBloc extends Bloc<AppEvent, AppState> {
  /// {@macro app_bloc}
  AppBloc({required ConnectionRepository connectionRepository})
    : _connectionRepository = connectionRepository,
      super(const AppState()) {
    on<AppStarted>(_onStarted);
  }

  final ConnectionRepository _connectionRepository;

  Future<void> _onStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    await emit.forEach(
      _connectionRepository.isConnected,
      onData: (isConnected) => AppState(
        status: isConnected ? AppStatus.connected : AppStatus.disconnected,
      ),
    );
  }
}
