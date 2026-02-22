import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_mobile_app/app/app.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((AppBloc bloc) => bloc.state.status);
    return switch (status) {
      AppStatus.initial || AppStatus.disconnected => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AppStatus.connected => const MenuGroupsPage(),
    };
  }
}
