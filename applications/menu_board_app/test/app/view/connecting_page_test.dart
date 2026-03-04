import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_menu_board_app/app/view/connecting_page.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ConnectingPage', () {
    testWidgets('renders CircularProgressIndicator and connecting text', (
      tester,
    ) async {
      await tester.pumpApp(const ConnectingPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Connecting...'), findsOneWidget);
    });
  });
}
