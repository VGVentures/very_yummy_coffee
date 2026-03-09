import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/menu_column.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('MenuColumn', () {
    const group = MenuGroup(
      id: 'g1',
      name: 'Espresso',
      description: 'Coffee drinks',
      color: 0xFF000000,
    );

    const item = MenuItem(
      id: 'i1',
      name: 'Americano',
      price: 400,
      groupId: 'g1',
    );

    testWidgets('renders group name, item name, and formatted price', (
      tester,
    ) async {
      await tester.pumpApp(
        const MenuColumn(
          groupEntries: [
            (group, [item]),
          ],
        ),
      );

      expect(find.text('Espresso'), findsOneWidget);
      expect(find.text('Americano'), findsOneWidget);
      expect(find.text(r'$4.00'), findsOneWidget);
    });

    testWidgets('renders without crash when groupEntries is empty', (
      tester,
    ) async {
      await tester.pumpApp(const MenuColumn(groupEntries: []));

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Not available for OOS item instead of price', (
      tester,
    ) async {
      const oosItem = MenuItem(
        id: 'i2',
        name: 'Latte',
        price: 500,
        groupId: 'g1',
        available: false,
      );

      await tester.pumpApp(
        const MenuColumn(
          groupEntries: [
            (group, [item, oosItem]),
          ],
        ),
      );

      expect(find.text('Americano'), findsOneWidget);
      expect(find.text(r'$4.00'), findsOneWidget);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Not available'), findsOneWidget);
      // OOS item should not show its price
      expect(find.text(r'$5.00'), findsNothing);
    });
  });
}
