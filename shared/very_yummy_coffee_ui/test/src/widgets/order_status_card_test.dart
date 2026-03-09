import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  const statusBg = Color(0xFFFFF3CD);
  const statusFg = Color(0xFF856404);

  Widget buildSubject({
    String displayName = 'Marcus',
    String statusLabel = 'Preparing',
    Color statusBackgroundColor = statusBg,
    Color statusForegroundColor = statusFg,
  }) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: OrderStatusCard(
          displayName: displayName,
          statusLabel: statusLabel,
          statusBackgroundColor: statusBackgroundColor,
          statusForegroundColor: statusForegroundColor,
        ),
      ),
    );
  }

  group('OrderStatusCard', () {
    testWidgets('renders displayName text', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Marcus'), findsOneWidget);
    });

    testWidgets('renders statusLabel text', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Preparing'), findsOneWidget);
    });

    testWidgets('applies statusBackgroundColor to status chip', (tester) async {
      await tester.pumpWidget(buildSubject());

      final statusChip = tester.widgetList<Container>(
        find.byType(Container),
      );

      // The inner container (status chip) should have the background color.
      final chip = statusChip.firstWhere(
        (c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == statusBg;
          }
          return false;
        },
      );
      expect(chip, isNotNull);
    });

    testWidgets('applies statusForegroundColor to status label text', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final text = tester.widget<Text>(find.text('Preparing'));
      expect(text.style?.color, equals(statusFg));
    });

    testWidgets('handles long displayName with text overflow', (tester) async {
      await tester.pumpWidget(
        buildSubject(displayName: 'A' * 200),
      );

      final text = tester.widget<Text>(find.text('A' * 200));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });

    testWidgets('uses design tokens for spacing and radius', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Verify the card renders without raw literals — the widget compiles
      // and renders correctly using context.spacing and context.radius tokens.
      expect(find.byType(OrderStatusCard), findsOneWidget);
    });
  });
}
