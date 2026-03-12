import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  Widget buildSubject({String? message}) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: Center(
          child: ConnectingView(message: message),
        ),
      ),
    );
  }

  group('ConnectingView', () {
    testWidgets('renders spinner only when message is null', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders spinner and text when message is set', (tester) async {
      await tester.pumpWidget(buildSubject(message: 'Connecting…'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Connecting…'), findsOneWidget);
    });

    testWidgets('builds without error when message is set with theme', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(message: 'Connecting…'));

      expect(find.byType(ConnectingView), findsOneWidget);
    });
  });
}
