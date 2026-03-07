import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';
import 'package:very_yummy_coffee_pos_app/menu/view/widgets/menu_item_grid.dart';

import '../../../helpers/pump_app.dart';

class _MockMenuBloc extends MockBloc<MenuEvent, MenuState>
    implements MenuBloc {}

const _tItem = MenuItem(
  id: 'i1',
  groupId: 'g1',
  name: 'Latte',
  price: 450,
);

const _tItemNoModifiers = MenuItem(
  id: 'i2',
  groupId: 'g2',
  name: 'Cookie',
  price: 300,
);

const _tSizeGroup = ModifierGroup(
  id: 'mg-size',
  name: 'Size',
  required: true,
  defaultOptionId: 'size-s',
  appliesToGroupIds: ['g1'],
  options: [
    ModifierOption(id: 'size-s', name: 'Small'),
    ModifierOption(id: 'size-m', name: 'Medium', priceDeltaCents: 50),
  ],
);

void main() {
  late _MockMenuBloc menuBloc;

  setUpAll(() {
    registerFallbackValue(const MenuSubscriptionRequested());
  });

  setUp(() {
    menuBloc = _MockMenuBloc();
  });

  Widget buildSubject({MenuState? state}) {
    final s = state ?? const MenuState();
    whenListen(menuBloc, const Stream<MenuState>.empty(), initialState: s);
    return BlocProvider<MenuBloc>.value(
      value: menuBloc,
      child: const MenuItemGrid(),
    );
  }

  group('MenuItemGrid', () {
    testWidgets('shows loading indicator when status is loading', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders item cards when status is success', (tester) async {
      await tester.pumpApp(
        buildSubject(
          state: const MenuState(
            status: MenuStatus.success,
            allItems: [_tItem, _tItemNoModifiers],
          ),
        ),
      );
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Cookie'), findsOneWidget);
    });

    testWidgets('dispatches MenuItemAdded directly when no modifiers apply', (
      tester,
    ) async {
      await tester.pumpApp(
        buildSubject(
          state: const MenuState(
            status: MenuStatus.success,
            allItems: [_tItemNoModifiers],
            modifierGroups: [_tSizeGroup],
          ),
        ),
      );
      await tester.tap(find.text('Add'));
      await tester.pump();

      final captured = verify(() => menuBloc.add(captureAny())).captured;
      expect(captured, hasLength(1));
      final event = captured.first as MenuItemAdded;
      expect(event.item, _tItemNoModifiers);
      expect(event.modifiers, isEmpty);
    });

    testWidgets('shows modifier bottom sheet when modifiers apply', (
      tester,
    ) async {
      await tester.pumpApp(
        buildSubject(
          state: const MenuState(
            status: MenuStatus.success,
            allItems: [_tItem],
            modifierGroups: [_tSizeGroup],
          ),
        ),
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Bottom sheet should be showing with modifier group content
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
      expect(find.text(r'Medium +$0.50'), findsOneWidget);
    });

    testWidgets(
      'dispatches MenuItemAdded with modifiers after bottom sheet confirm',
      (tester) async {
        await tester.pumpApp(
          buildSubject(
            state: const MenuState(
              status: MenuStatus.success,
              allItems: [_tItem],
              modifierGroups: [_tSizeGroup],
            ),
          ),
        );
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        // Select Medium and confirm
        await tester.tap(find.text(r'Medium +$0.50'));
        await tester.pump();
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        final captured = verify(() => menuBloc.add(captureAny())).captured;
        expect(captured, hasLength(1));
        final event = captured.first as MenuItemAdded;
        expect(event.item, _tItem);
        expect(event.modifiers, hasLength(1));
        expect(event.modifiers.first.modifierGroupId, 'mg-size');
        expect(event.modifiers.first.options.first.id, 'size-m');
        expect(event.modifiers.first.options.first.priceDeltaCents, 50);
      },
    );

    testWidgets(
      'does not dispatch event when bottom sheet is dismissed',
      (tester) async {
        await tester.pumpApp(
          buildSubject(
            state: const MenuState(
              status: MenuStatus.success,
              allItems: [_tItem],
              modifierGroups: [_tSizeGroup],
            ),
          ),
        );
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        // Dismiss by tapping barrier
        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();

        verifyNever(() => menuBloc.add(any()));
      },
    );
  });
}
