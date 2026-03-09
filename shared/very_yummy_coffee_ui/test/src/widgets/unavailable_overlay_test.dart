import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  Widget buildSubject({required bool isUnavailable}) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: UnavailableOverlay(
          isUnavailable: isUnavailable,
          child: const SizedBox(
            width: 100,
            height: 100,
            child: Text('Item'),
          ),
        ),
      ),
    );
  }

  group('UnavailableOverlay', () {
    testWidgets('renders child without overlay when available', (tester) async {
      await tester.pumpWidget(buildSubject(isUnavailable: false));

      expect(find.text('Item'), findsOneWidget);
      expect(find.byType(OutOfStockBadge), findsNothing);
    });

    testWidgets('renders child with overlay when unavailable', (tester) async {
      await tester.pumpWidget(buildSubject(isUnavailable: true));

      expect(find.text('Item'), findsOneWidget);
      expect(find.byType(OutOfStockBadge), findsOneWidget);
    });

    testWidgets('renders overlay with DecoratedBox', (tester) async {
      await tester.pumpWidget(buildSubject(isUnavailable: true));

      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('has semantics label when unavailable', (tester) async {
      await tester.pumpWidget(buildSubject(isUnavailable: true));

      final semantics = tester.getSemantics(
        find.byType(UnavailableOverlay),
      );
      expect(semantics.label, contains('Unavailable'));
    });
  });
}
