import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  Widget buildSubject({required List<String> labels}) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: ModifierSummaryChips(labels: labels),
      ),
    );
  }

  group('ModifierSummaryChips', () {
    testWidgets('renders all labels as chips', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          labels: ['Oat Milk', 'Grande', 'Vanilla'],
        ),
      );

      expect(find.text('Oat Milk'), findsOneWidget);
      expect(find.text('Grande'), findsOneWidget);
      expect(find.text('Vanilla'), findsOneWidget);
    });

    testWidgets('renders nothing for empty labels', (tester) async {
      await tester.pumpWidget(
        buildSubject(labels: const []),
      );

      expect(
        find.byType(ModifierSummaryChips),
        findsOneWidget,
      );
      // SizedBox.shrink is rendered
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('renders single label', (tester) async {
      await tester.pumpWidget(
        buildSubject(labels: ['Iced']),
      );

      expect(find.text('Iced'), findsOneWidget);
    });
  });
}
