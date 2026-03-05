import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_menu_board_app/app/app.dart';
import 'package:very_yummy_coffee_menu_board_app/l10n/arb/app_localizations.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

import 'go_router.dart';

class _MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class _MockMenuRepository extends Mock implements MenuRepository {}

AppBloc _defaultAppBloc() {
  final bloc = _MockAppBloc();
  when(() => bloc.state).thenReturn(
    const AppState(status: AppStatus.connected),
  );
  return bloc;
}

extension AppTester on WidgetTester {
  Future<void> pumpApp(
    Widget widgetUnderTest, {
    AppBloc? appBloc,
    GoRouter? goRouter,
    MenuRepository? menuRepository,
  }) async {
    await pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<MenuRepository>.value(
            value: menuRepository ?? _MockMenuRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appBloc ?? _defaultAppBloc()),
          ],
          child: MockGoRouterProvider(
            goRouter: goRouter ?? MockGoRouter(),
            child: MaterialApp(
              theme: CoffeeTheme.light,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: widgetUnderTest),
            ),
          ),
        ),
      ),
    );
    await pump();
  }
}
