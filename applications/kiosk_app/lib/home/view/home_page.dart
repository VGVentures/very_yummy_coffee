import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kiosk_app/home/home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  factory HomePage.pageBuilder(
    BuildContext _,
    GoRouterState _,
  ) => const HomePage(key: Key('home_page'));

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}
