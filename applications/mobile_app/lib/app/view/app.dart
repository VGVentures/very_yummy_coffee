import 'package:connection_repository/connection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_mobile_app/app/app.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppBloc(
        connectionRepository: context.read<ConnectionRepository>(),
      )..add(const AppStarted()),
      child: MaterialApp(
        theme: CoffeeTheme.light,
        home: const AppView(),
      ),
    );
  }
}
