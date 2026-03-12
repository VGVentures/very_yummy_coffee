import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_feature/menu_feature.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  final testGroups = [
    const MenuGroup(
      id: '1',
      name: 'Coffee',
      description: 'Hot drinks',
      color: 0xFFC96B45,
    ),
    const MenuGroup(
      id: '2',
      name: 'Pastries',
      description: 'Baked goods',
      color: 0xFFE7BD5A,
    ),
  ];

  Widget buildSubject({
    required List<MenuGroup> groups,
    required void Function(MenuGroup) onGroupTap,
  }) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: MenuGroupList(
          groups: groups,
          onGroupTap: onGroupTap,
        ),
      ),
    );
  }

  group('MenuGroupList', () {
    testWidgets('renders group names', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          groups: testGroups,
          onGroupTap: (_) {},
        ),
      );

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Pastries'), findsOneWidget);
    });

    testWidgets('invokes onGroupTap when a group is tapped', (tester) async {
      MenuGroup? tapped;
      await tester.pumpWidget(
        buildSubject(
          groups: testGroups,
          onGroupTap: (g) => tapped = g,
        ),
      );

      await tester.tap(find.text('Coffee'));
      await tester.pump();

      expect(tapped?.id, '1');
      expect(tapped?.name, 'Coffee');
    });

    testWidgets('renders nothing when groups empty', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          groups: [],
          onGroupTap: (_) {},
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
