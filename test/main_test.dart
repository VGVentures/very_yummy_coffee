import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee/main.dart' as app;

void main() {
  testWidgets('should MainApp contain a [Hello World!] text', (tester) async {
    await tester.pumpWidget(const app.MainApp());

    expect(find.text('Hello World!'), findsOneWidget);
  });

  testWidgets('startApp runs and mounts MainApp', (tester) async {
    app.startApp();

    await tester.pump();

    expect(find.text('Hello World!'), findsOneWidget);
  });

  testWidgets('should [startApp] starts the app', (WidgetTester tester) async {
    app.startApp();

    await tester.pumpAndSettle();

    expect(find.text('Hello World!'), findsOneWidget);
  });

  testWidgets('library main() calls startApp', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    expect(find.text('Hello World!'), findsOneWidget);
  });
}
