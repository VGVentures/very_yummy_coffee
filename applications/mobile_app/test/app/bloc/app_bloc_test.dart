import 'package:bloc_test/bloc_test.dart';
import 'package:connection_repository/connection_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_mobile_app/app/app.dart';

class _MockConnectionRepository extends Mock implements ConnectionRepository {}

void main() {
  group('AppBloc', () {
    late ConnectionRepository connectionRepository;

    setUp(() {
      connectionRepository = _MockConnectionRepository();
    });

    test('initial state is AppState with AppStatus.initial', () {
      when(
        () => connectionRepository.isConnected,
      ).thenAnswer((_) => const Stream.empty());
      expect(
        AppBloc(connectionRepository: connectionRepository).state,
        const AppState(),
      );
    });

    group('AppStarted', () {
      blocTest<AppBloc, AppState>(
        'emits [connected] when isConnected emits true',
        build: () {
          when(
            () => connectionRepository.isConnected,
          ).thenAnswer((_) => Stream.value(true));
          return AppBloc(connectionRepository: connectionRepository);
        },
        act: (bloc) => bloc.add(const AppStarted()),
        expect: () => [const AppState(status: AppStatus.connected)],
      );

      blocTest<AppBloc, AppState>(
        'emits [disconnected] when isConnected emits false',
        build: () {
          when(
            () => connectionRepository.isConnected,
          ).thenAnswer((_) => Stream.value(false));
          return AppBloc(connectionRepository: connectionRepository);
        },
        act: (bloc) => bloc.add(const AppStarted()),
        expect: () => [const AppState(status: AppStatus.disconnected)],
      );

      blocTest<AppBloc, AppState>(
        'emits [connected, disconnected] when connection drops',
        build: () {
          when(
            () => connectionRepository.isConnected,
          ).thenAnswer((_) => Stream.fromIterable([true, false]));
          return AppBloc(connectionRepository: connectionRepository);
        },
        act: (bloc) => bloc.add(const AppStarted()),
        expect: () => [
          const AppState(status: AppStatus.connected),
          const AppState(status: AppStatus.disconnected),
        ],
      );

      blocTest<AppBloc, AppState>(
        'emits [disconnected, connected] when connection recovers',
        build: () {
          when(
            () => connectionRepository.isConnected,
          ).thenAnswer((_) => Stream.fromIterable([false, true]));
          return AppBloc(connectionRepository: connectionRepository);
        },
        act: (bloc) => bloc.add(const AppStarted()),
        expect: () => [
          const AppState(status: AppStatus.disconnected),
          const AppState(status: AppStatus.connected),
        ],
      );
    });
  });
}
