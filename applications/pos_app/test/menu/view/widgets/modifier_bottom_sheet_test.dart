import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/modifier_bottom_sheet.dart';

import '../../../helpers/pump_app.dart';

const _tItem = MenuItem(
  id: 'i1',
  groupId: 'g1',
  name: 'Latte',
  price: 450,
);

const _tSizeGroup = ModifierGroup(
  id: 'mg-size',
  name: 'Size',
  required: true,
  defaultOptionId: 'size-s',
  options: [
    ModifierOption(id: 'size-s', name: 'Small'),
    ModifierOption(id: 'size-m', name: 'Medium', priceDeltaCents: 50),
    ModifierOption(id: 'size-l', name: 'Large', priceDeltaCents: 100),
  ],
);

const _tSyrupGroup = ModifierGroup(
  id: 'mg-syrup',
  name: 'Syrup',
  selectionMode: SelectionMode.multi,
  options: [
    ModifierOption(id: 'syrup-v', name: 'Vanilla', priceDeltaCents: 75),
    ModifierOption(id: 'syrup-c', name: 'Caramel', priceDeltaCents: 75),
  ],
);

void main() {
  group('ModifierBottomSheet', () {
    late List<SelectedModifier>? result;

    Future<void> showSheet(
      WidgetTester tester, {
      List<ModifierGroup> modifierGroups = const [_tSizeGroup],
    }) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showModifierBottomSheet(
                context: context,
                item: _tItem,
                modifierGroups: modifierGroups,
              );
            },
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows item name', (tester) async {
      await showSheet(tester);
      expect(find.text('Latte'), findsOneWidget);
    });

    testWidgets('shows modifier group name', (tester) async {
      await showSheet(tester);
      expect(find.text('Size'), findsOneWidget);
    });

    testWidgets('shows all option names', (tester) async {
      await showSheet(tester);
      expect(find.text('Small'), findsOneWidget);
      expect(find.text(r'Medium +$0.50'), findsOneWidget);
      expect(find.text(r'Large +$1.00'), findsOneWidget);
    });

    testWidgets('pre-selects default option', (tester) async {
      await showSheet(tester);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.first.options.first.id, 'size-s');
    });

    testWidgets('tapping option changes selection for single-select', (
      tester,
    ) async {
      await showSheet(tester);
      await tester.tap(find.text(r'Medium +$0.50'));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.first.options.length, 1);
      expect(result!.first.options.first.id, 'size-m');
      expect(result!.first.options.first.name, 'Medium');
      expect(result!.first.options.first.priceDeltaCents, 50);
    });

    testWidgets('multi-select allows multiple options', (tester) async {
      await showSheet(
        tester,
        modifierGroups: const [_tSyrupGroup],
      );
      await tester.tap(find.text(r'Vanilla +$0.75'));
      await tester.pump();
      await tester.tap(find.text(r'Caramel +$0.75'));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.first.options.length, 2);
    });

    testWidgets('confirm is disabled when required group has no selection', (
      tester,
    ) async {
      const requiredNoDefault = ModifierGroup(
        id: 'mg-req',
        name: 'Required',
        required: true,
        options: [
          ModifierOption(id: 'opt-a', name: 'Option A'),
          ModifierOption(id: 'opt-b', name: 'Option B'),
        ],
      );
      await showSheet(
        tester,
        modifierGroups: const [requiredNoDefault],
      );
      // BaseButton renders a TextButton for primary variant.
      // When disabled, onPressed is null.
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Confirm'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('returns null when dismissed', (tester) async {
      result = const [];
      await showSheet(tester);
      // Dismiss by tapping the barrier
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('propagates priceDeltaCents in result', (tester) async {
      await showSheet(tester);
      await tester.tap(find.text(r'Large +$1.00'));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.first.options.first.priceDeltaCents, 100);
    });
  });
}
