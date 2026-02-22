import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_mobile_app/app/app.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/arb/app_localizations.dart';

import 'go_router.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

extension AppTester on WidgetTester {
  Future<void> pumpApp(
    Widget widgetUnderTest, {
    AppBloc? appBloc,
    GoRouter? goRouter,
  }) async {
    await pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appBloc ?? MockAppBloc()),
        ],
        child: MockGoRouterProvider(
          goRouter: goRouter ?? MockGoRouter(),
          child: MaterialApp(
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
    );
    await pump();
  }
}
