import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildSubject(MenuItemImage child) {
    return MaterialApp(
      theme: CoffeeTheme.light,
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 200,
          child: child,
        ),
      ),
    );
  }

  group('MenuItemImage', () {
    testWidgets('null URL shows cafe placeholder', (tester) async {
      await tester.pumpWidget(
        buildSubject(const MenuItemImage()),
      );

      expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
    });

    testWidgets('blank URL shows cafe placeholder', (tester) async {
      await tester.pumpWidget(
        buildSubject(const MenuItemImage(imageUrl: '   ')),
      );

      expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
    });

    testWidgets(
      'non-null URL with failed fetch shows cafe placeholder',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            const MenuItemImage(
              imageUrl: 'http://127.0.0.1:1/menu-item-image-test-missing',
            ),
          ),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
      },
    );

    testWidgets('thumbnail layout uses fixed extent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CoffeeTheme.light,
          home: const Scaffold(
            body: Center(
              child: MenuItemImage(
                layout: MenuItemImageLayout.thumbnail,
              ),
            ),
          ),
        ),
      );

      final clipBox = tester.renderObject<RenderBox>(
        find.descendant(
          of: find.byType(MenuItemImage),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clipBox.hasSize, isTrue);
      expect(clipBox.size.width, MenuItemImage.thumbnailExtent);
      expect(clipBox.size.height, MenuItemImage.thumbnailExtent);
    });
  });
}
