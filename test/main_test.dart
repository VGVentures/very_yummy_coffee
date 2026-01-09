import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee/main.dart';

void main() {
  testWidgets('should MainApp contain a [Hello World!] text', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Hello World!'), findsOneWidget);
  });
}
