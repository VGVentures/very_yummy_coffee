import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  const statusBg = Color(0xFFFFF3CD);
  const statusFg = Color(0xFF856404);

  Widget buildSubject({
    String label = 'Preparing',
    Color backgroundColor = statusBg,
    Color foregroundColor = statusFg,
  }) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: StatusBadge(
          label: label,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }

  group('StatusBadge', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Preparing'), findsOneWidget);
    });

    testWidgets('applies backgroundColor to pill', (tester) async {
      await tester.pumpWidget(buildSubject());

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(StatusBadge),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, equals(statusBg));
    });

    testWidgets('applies foregroundColor to label text', (tester) async {
      await tester.pumpWidget(buildSubject());

      final text = tester.widget<Text>(find.text('Preparing'));
      expect(text.style?.color, equals(statusFg));
    });

    testWidgets('allows empty label', (tester) async {
      await tester.pumpWidget(buildSubject(label: ''));

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });
  });
}
