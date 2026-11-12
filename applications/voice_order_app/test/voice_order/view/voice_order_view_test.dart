import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/voice_order.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/widgets/widgets.dart';

import '../../helpers/fakes.dart';

void main() {
  group('VoiceOrderView', () {
    late FakeTranscriber transcriber;
    late FakeDecisionClient decisionClient;

    Future<void> pumpView(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: CoffeeTheme.light,
          home: BlocProvider(
            create: (_) => VoiceOrderBloc(
              transcriber: transcriber,
              decisionClient: decisionClient,
            ),
            child: const VoiceOrderView(),
          ),
        ),
      );
    }

    setUp(() {
      transcriber = FakeTranscriber();
      decisionClient = FakeDecisionClient();
    });

    testWidgets('greets the customer before anything is ordered', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text('What can I get started for you?'), findsOneWidget);
      expect(find.text('Tap the mic and order out loud'), findsOneWidget);
      expect(find.byType(DrinkCard), findsNothing);
    });

    testWidgets('shows what is said, then a card for each drink', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      transcriber.session.add('an iced oat latte and a mocha');
      await tester.pump();

      expect(
        find.textContaining(
          'an iced oat latte and a mocha',
          findRichText: true,
        ),
        findsOneWidget,
      );

      decisionClient.replies.single.complete([
        DrinkOrder.withDefaults(
          VoiceMenu.byId('latte')!,
          milk: Milk.oat,
          temperature: Temperature.iced,
        ),
        DrinkOrder.withDefaults(VoiceMenu.byId('mocha')!),
      ]);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(DrinkCard), findsNWidgets(2));
      expect(find.text('Iced Latte'), findsOneWidget);
      expect(find.text('Oat milk'), findsOneWidget);
      expect(find.text('Mocha'), findsOneWidget);
      // 525 + 75 oat, plus 575.
      expect(find.text(r'2 drinks  ·  $11.75'), findsOneWidget);
    });

    testWidgets('start over clears the order', (tester) async {
      await pumpView(tester);
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      transcriber.session.add('a mocha');
      await tester.pump();
      decisionClient.replies.single.complete([
        DrinkOrder.withDefaults(VoiceMenu.byId('mocha')!),
      ]);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      await tester.tap(find.text('Start over'));
      // Cancelling the transcript stream completes on the real event loop.
      await tester.runAsync(pumpEventQueue);
      await tester.pump();

      expect(find.byType(DrinkCard), findsNothing);
      expect(find.text('What can I get started for you?'), findsOneWidget);
    });
  });
}
