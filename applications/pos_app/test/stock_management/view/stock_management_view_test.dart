import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/stock_management.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/view/widgets/stock_item_tile.dart';

import '../../helpers/pump_app.dart';

class _MockStockManagementBloc
    extends MockBloc<StockManagementEvent, StockManagementState>
    implements StockManagementBloc {}

void main() {
  const tGroup = MenuGroup(
    id: 'g1',
    name: 'Espresso',
    description: 'Espresso drinks',
    color: 0xFF795548,
  );
  const tItem = MenuItem(
    id: '101',
    groupId: 'g1',
    name: 'Latte',
    price: 550,
  );
  const tUnavailableItem = MenuItem(
    id: '102',
    groupId: 'g1',
    name: 'Mocha',
    price: 600,
    available: false,
  );

  setUpAll(() {
    registerFallbackValue(
      const StockManagementSubscriptionRequested(),
    );
  });

  group('StockManagementView', () {
    late StockManagementBloc bloc;

    setUp(() {
      bloc = _MockStockManagementBloc();
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => bloc.state).thenReturn(const StockManagementState());

      await tester.pumpApp(
        BlocProvider<StockManagementBloc>.value(
          value: bloc,
          child: const StockManagementView(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text when failure', (tester) async {
      when(() => bloc.state).thenReturn(
        const StockManagementState(status: StockManagementStatus.failure),
      );

      await tester.pumpApp(
        BlocProvider<StockManagementBloc>.value(
          value: bloc,
          child: const StockManagementView(),
        ),
      );

      expect(find.text('Unable to load menu'), findsOneWidget);
    });

    testWidgets('shows group header and items on success', (tester) async {
      when(() => bloc.state).thenReturn(
        const StockManagementState(
          status: StockManagementStatus.success,
          groups: [tGroup],
          items: [tItem, tUnavailableItem],
        ),
      );

      await tester.pumpApp(
        BlocProvider<StockManagementBloc>.value(
          value: bloc,
          child: const StockManagementView(),
        ),
      );

      expect(find.text('Espresso'), findsOneWidget);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Mocha'), findsOneWidget);
      expect(find.byType(StockItemTile), findsNWidgets(2));
    });

    testWidgets('shows item count per group', (tester) async {
      when(() => bloc.state).thenReturn(
        const StockManagementState(
          status: StockManagementStatus.success,
          groups: [tGroup],
          items: [tItem, tUnavailableItem],
        ),
      );

      await tester.pumpApp(
        BlocProvider<StockManagementBloc>.value(
          value: bloc,
          child: const StockManagementView(),
        ),
      );

      expect(find.text('1/2 in stock'), findsOneWidget);
    });

    testWidgets('toggling switch adds StockManagementItemToggled event', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const StockManagementState(
          status: StockManagementStatus.success,
          groups: [tGroup],
          items: [tItem],
        ),
      );

      await tester.pumpApp(
        BlocProvider<StockManagementBloc>.value(
          value: bloc,
          child: const StockManagementView(),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();

      final captured =
          verify(() => bloc.add(captureAny())).captured.single
              as StockManagementItemToggled;
      expect(captured.itemId, '101');
      expect(captured.available, isFalse);
    });
  });
}
