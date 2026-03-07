import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/app/app.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    OrderRepository? orderRepository,
    AppBloc? appBloc,
  }) async {
    final effectiveAppBloc = appBloc ?? MockAppBloc();
    if (appBloc == null) {
      whenListen(
        effectiveAppBloc,
        const Stream<AppState>.empty(),
        initialState: const AppState(status: AppStatus.connected),
      );
    }

    Widget app = MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>.value(value: effectiveAppBloc),
      ],
      child: MaterialApp(
        theme: CoffeeTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: widget),
      ),
    );

    if (orderRepository != null) {
      app = RepositoryProvider.value(
        value: orderRepository,
        child: app,
      );
    }

    await pumpWidget(app);
    await pump();
  }
}
