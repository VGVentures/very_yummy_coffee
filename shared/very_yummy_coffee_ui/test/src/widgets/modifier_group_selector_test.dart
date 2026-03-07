import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  Widget buildSubject({
    required List<ModifierOptionData> options,
    required ValueChanged<int> onOptionToggled,
    bool isRequired = false,
    bool isMultiSelect = false,
    String groupName = 'Size',
  }) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: ModifierGroupSelector(
          groupName: groupName,
          options: options,
          onOptionToggled: onOptionToggled,
          isRequired: isRequired,
          isMultiSelect: isMultiSelect,
        ),
      ),
    );
  }

  group('ModifierGroupSelector', () {
    testWidgets('renders group name', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          options: const [ModifierOptionData(name: 'Tall')],
          onOptionToggled: (_) {},
        ),
      );

      expect(find.text('Size'), findsOneWidget);
    });

    testWidgets('shows required badge when isRequired is true', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          options: const [ModifierOptionData(name: 'Tall')],
          onOptionToggled: (_) {},
          isRequired: true,
        ),
      );

      expect(find.text('(required)'), findsOneWidget);
    });

    testWidgets('hides required badge when isRequired is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          options: const [ModifierOptionData(name: 'Tall')],
          onOptionToggled: (_) {},
        ),
      );

      expect(find.text('(required)'), findsNothing);
    });

    testWidgets('renders all option chips', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          options: const [
            ModifierOptionData(name: 'Short'),
            ModifierOptionData(name: 'Tall'),
            ModifierOptionData(name: 'Grande'),
          ],
          onOptionToggled: (_) {},
        ),
      );

      expect(find.text('Short'), findsOneWidget);
      expect(find.text('Tall'), findsOneWidget);
      expect(find.text('Grande'), findsOneWidget);
    });

    testWidgets('shows price delta for options with priceDeltaCents > 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          options: const [
            ModifierOptionData(name: 'Tall'),
            ModifierOptionData(
              name: 'Grande',
              priceDeltaCents: 50,
            ),
          ],
          onOptionToggled: (_) {},
        ),
      );

      expect(find.text('Tall'), findsOneWidget);
      expect(find.text(r'Grande +$0.50'), findsOneWidget);
    });

    testWidgets(
      'does not show price for options with zero delta',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            options: const [
              ModifierOptionData(name: 'Whole Milk'),
            ],
            onOptionToggled: (_) {},
          ),
        );

        expect(find.text('Whole Milk'), findsOneWidget);
        expect(find.textContaining(r'+$'), findsNothing);
      },
    );

    testWidgets('calls onOptionToggled with correct index on tap', (
      tester,
    ) async {
      var tappedIndex = -1;

      await tester.pumpWidget(
        buildSubject(
          options: const [
            ModifierOptionData(name: 'Short'),
            ModifierOptionData(name: 'Tall'),
          ],
          onOptionToggled: (i) => tappedIndex = i,
        ),
      );

      await tester.tap(find.text('Tall'));
      expect(tappedIndex, 1);

      await tester.tap(find.text('Short'));
      expect(tappedIndex, 0);
    });
  });
}
