import 'package:flutter/material.dart';
import 'package:very_yummy_coffee/core/core.dart';

void main() => startApp();

void startApp() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
