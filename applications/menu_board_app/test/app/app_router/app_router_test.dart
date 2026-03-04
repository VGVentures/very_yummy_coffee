import 'package:connection_repository/connection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_menu_board_app/app/view/app.dart';

class _MockConnectionRepository extends Mock implements ConnectionRepository {}

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('AppRouter', () {
    late ConnectionRepository connectionRepository;
    late MenuRepository menuRepository;

    setUp(() {
      connectionRepository = _MockConnectionRepository();
      menuRepository = _MockMenuRepository();
    });

    Widget buildApp() => MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ConnectionRepository>.value(
          value: connectionRepository,
        ),
        RepositoryProvider<MenuRepository>.value(value: menuRepository),
      ],
      child: const App(),
    );

    testWidgets('shows ConnectingPage when status is disconnected', (
      tester,
    ) async {
      when(
        () => connectionRepository.isConnected,
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('connecting_page')), findsOneWidget);
    });

    testWidgets('redirects to MenuDisplayPage when status is connected', (
      tester,
    ) async {
      when(
        () => connectionRepository.isConnected,
      ).thenAnswer((_) => Stream.value(true));
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('menu_display_page')), findsOneWidget);
    });

    testWidgets('redirects to ConnectingPage when connection drops', (
      tester,
    ) async {
      when(
        () => connectionRepository.isConnected,
      ).thenAnswer((_) => Stream.fromIterable([true, false]));
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('connecting_page')), findsOneWidget);
    });
  });
}
