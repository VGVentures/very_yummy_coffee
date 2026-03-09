import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  Widget buildSubject({String label = 'Unavailable'}) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(body: OutOfStockBadge(label: label)),
    );
  }

  group('OutOfStockBadge', () {
    testWidgets('renders default label', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('renders custom label', (tester) async {
      await tester.pumpWidget(buildSubject(label: 'Sold Out'));

      expect(find.text('Sold Out'), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpWidget(buildSubject());

      final semantics = tester.getSemantics(find.byType(OutOfStockBadge));
      expect(semantics.label, contains('Unavailable'));
    });
  });
}
