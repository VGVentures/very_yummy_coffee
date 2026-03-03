import 'package:bloc/bloc.dart';
import 'package:connection_repository/connection_repository.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'app_bloc.mapper.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
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
