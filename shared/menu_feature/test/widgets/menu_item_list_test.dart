import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  const groupId = 'drinks';
  final testItems = [
    const MenuItem(
      id: '1',
      name: 'Espresso',
      price: 300,
      groupId: groupId,
    ),
    const MenuItem(
      id: '2',
      name: 'Latte',
      price: 475,
      groupId: groupId,
    ),
  ];

  Widget buildSubject({
    required List<MenuItem> items,
    required void Function(MenuItem) onItemTap,
  }) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: MenuItemList(
          items: items,
          onItemTap: onItemTap,
        ),
      ),
    );
  }

  group('MenuItemList', () {
    testWidgets('renders item names and prices', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          items: testItems,
          onItemTap: (_) {},
        ),
      );

      expect(find.text('Espresso'), findsOneWidget);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text(r'$3.00'), findsOneWidget);
      expect(find.text(r'$4.75'), findsOneWidget);
    });

    testWidgets('invokes onItemTap when an item is tapped', (tester) async {
      MenuItem? tapped;
      await tester.pumpWidget(
        buildSubject(
          items: testItems,
          onItemTap: (i) => tapped = i,
        ),
      );

      await tester.tap(find.text('Espresso'));
      await tester.pump();

      expect(tapped?.id, '1');
      expect(tapped?.name, 'Espresso');
    });
  });
}
