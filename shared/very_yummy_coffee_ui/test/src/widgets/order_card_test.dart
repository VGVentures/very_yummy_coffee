import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  const statusBg = Color(0xFFDCFCE7);
  const statusFg = Color(0xFF166534);

  Widget buildSubject({
    String orderNumber = '#42',
    String? customerName = 'Marcus',
    List<String> lineSummaries = const ['2× Espresso', '1× Latte'],
    String totalDisplayText = r'$12.50',
    String? statusLabel = 'Ready',
    Color? statusBackgroundColor = statusBg,
    Color? statusForegroundColor = statusFg,
    String? elapsed,
    Widget? elapsedWidget,
    Widget? trailing,
  }) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: OrderCard(
          orderNumber: orderNumber,
          customerName: customerName,
          lineSummaries: lineSummaries,
          totalDisplayText: totalDisplayText,
          statusLabel: statusLabel,
          statusBackgroundColor: statusBackgroundColor,
          statusForegroundColor: statusForegroundColor,
          elapsed: elapsed,
          elapsedWidget: elapsedWidget,
          trailing: trailing,
        ),
      ),
    );
  }

  group('OrderCard', () {
    testWidgets('renders order number and status', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('#42'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('renders total display text', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text(r'$12.50'), findsOneWidget);
    });

    testWidgets('shows customer name when provided', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Marcus'), findsOneWidget);
    });

    testWidgets('omits customer line when customerName is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(customerName: null));

      expect(find.text('Marcus'), findsNothing);
    });

    testWidgets('omits customer line when customerName is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(customerName: ''));

      expect(find.text('Marcus'), findsNothing);
    });

    testWidgets('shows elapsed when provided', (tester) async {
      await tester.pumpWidget(buildSubject(elapsed: '5 min'));

      expect(find.text('5 min'), findsOneWidget);
    });

    testWidgets('omits elapsed when null', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('5 min'), findsNothing);
    });

    testWidgets('shows line summaries when non-empty', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('2× Espresso'), findsOneWidget);
      expect(find.text('1× Latte'), findsOneWidget);
    });

    testWidgets('hides line section when lineSummaries is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(lineSummaries: const []),
      );

      expect(find.text('2× Espresso'), findsNothing);
      expect(find.text('1× Latte'), findsNothing);
    });

    testWidgets('shows trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          trailing: const Text('Actions'),
        ),
      );

      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('order number has ellipsis overflow', (tester) async {
      await tester.pumpWidget(
        buildSubject(orderNumber: 'A' * 100),
      );

      final text = tester.widget<Text>(find.text('A' * 100));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });

    testWidgets('uses StatusBadge for status pill when status provided', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('omits status pill when statusLabel is null', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          statusLabel: null,
          statusBackgroundColor: null,
          statusForegroundColor: null,
        ),
      );

      expect(find.byType(StatusBadge), findsNothing);
    });

    testWidgets(
      'shows elapsedWidget when provided and ignores elapsed string',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            elapsed: '5 min',
            elapsedWidget: const Text('Custom elapsed'),
          ),
        );

        expect(find.text('Custom elapsed'), findsOneWidget);
        expect(find.text('5 min'), findsNothing);
      },
    );
  });
}
