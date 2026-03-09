import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/featured_item_panel.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('FeaturedItemPanel', () {
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

    testWidgets('renders group name', (tester) async {
      await tester.pumpApp(const FeaturedItemPanel(group: group, item: null));

      expect(find.text('Espresso'), findsOneWidget);
    });

    testWidgets('renders Not available when item is null', (tester) async {
      await tester.pumpApp(const FeaturedItemPanel(group: group, item: null));

      expect(find.text('Not available'), findsOneWidget);
    });

    testWidgets('renders item name and formatted price when item is present', (
      tester,
    ) async {
      await tester.pumpApp(const FeaturedItemPanel(group: group, item: item));

      expect(find.text('Americano'), findsOneWidget);
      expect(find.text(r'$4.00'), findsOneWidget);
    });

    testWidgets('shows Not available for OOS featured item', (tester) async {
      const oosItem = MenuItem(
        id: 'i1',
        name: 'Americano',
        price: 400,
        groupId: 'g1',
        available: false,
      );

      await tester.pumpApp(
        const FeaturedItemPanel(group: group, item: oosItem),
      );

      expect(find.text('Americano'), findsOneWidget);
      expect(find.text('Not available'), findsOneWidget);
      // Should not show the price pill
      expect(find.text(r'$4.00'), findsNothing);
    });
  });
}
