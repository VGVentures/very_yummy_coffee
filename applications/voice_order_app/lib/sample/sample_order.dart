import 'dart:async';

import 'package:very_yummy_coffee_voice_order_app/decisions/decisions.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech.dart';

/// A recorded order that plays back without a microphone or an API key.
///
/// Nothing here is worked out by a model: each phrase is paired with the
/// order as it stands once that phrase has been spoken. It exists to show
/// the screen in motion and to exercise the same bloc the live clients use.
abstract final class SampleOrder {
  static final List<({String phrase, List<DrinkOrder> order})> steps = () {
    final matcha = VoiceMenu.byId('matcha_latte')!;
    final cappuccino = VoiceMenu.byId('cappuccino')!;
    final latte = VoiceMenu.byId('latte')!;

    final icedMatcha = DrinkOrder.withDefaults(
      matcha,
      temperature: Temperature.iced,
    );
    final icedOatMatcha = DrinkOrder.withDefaults(
      matcha,
      temperature: Temperature.iced,
      milk: Milk.oat,
    );
    final aCappuccino = DrinkOrder.withDefaults(cappuccino);
    final aLatte = DrinkOrder.withDefaults(latte);
    final largeLatte = DrinkOrder.withDefaults(latte, size: DrinkSize.venti);
    final shortLatte = DrinkOrder.withDefaults(latte, size: DrinkSize.short);

    return [
      (
        phrase: 'hi can I get a matcha latte',
        order: [DrinkOrder.withDefaults(matcha)],
      ),
      (phrase: "let's make it iced", order: [icedMatcha]),
      (phrase: 'with oat milk', order: [icedOatMatcha]),
      (
        phrase: 'and can we add one cappuccino',
        order: [icedOatMatcha, aCappuccino],
      ),
      (phrase: 'and one latte', order: [icedOatMatcha, aCappuccino, aLatte]),
      (
        phrase: 'actually can we add one more',
        order: [icedOatMatcha, aCappuccino, aLatte, aLatte],
      ),
      (
        phrase: 'for one of the lattes can we make it a large',
        order: [icedOatMatcha, aCappuccino, largeLatte, aLatte],
      ),
      (
        phrase: 'and the other one a short',
        order: [icedOatMatcha, aCappuccino, largeLatte, shortLatte],
      ),
      (
        phrase: 'and for the short one can we do three shots with oat milk',
        order: [
          icedOatMatcha,
          aCappuccino,
          largeLatte,
          DrinkOrder.withDefaults(
            latte,
            size: DrinkSize.short,
            shots: 3,
            milk: Milk.oat,
          ),
        ],
      ),
      (
        phrase: "and let's make that one iced actually",
        order: [
          icedOatMatcha,
          aCappuccino,
          largeLatte,
          DrinkOrder.withDefaults(
            latte,
            size: DrinkSize.short,
            shots: 3,
            milk: Milk.oat,
            temperature: Temperature.iced,
          ),
        ],
      ),
    ];
  }();
}

/// Speaks [SampleOrder] one word at a time.
class SampleTranscriber implements SpeechTranscriber {
  const SampleTranscriber({
    this.wordInterval = const Duration(milliseconds: 260),
  });

  final Duration wordInterval;

  @override
  Stream<String> listen() async* {
    yield '';
    final words = SampleOrder.steps
        .expand((step) => step.phrase.split(' '))
        .toList();
    for (var count = 1; count <= words.length; count++) {
      await Future<void>.delayed(wordInterval);
      yield words.take(count).join(' ');
    }
  }
}

/// Answers with the recorded order for however much of [SampleOrder] has
/// been spoken.
class SampleDecisionClient implements DecisionClient {
  const SampleDecisionClient({
    this.delay = const Duration(milliseconds: 150),
  });

  /// Stands in for the round trip to the model.
  final Duration delay;

  @override
  Future<List<DrinkOrder>> decideOrder(String transcript) async {
    await Future<void>.delayed(delay);
    final spoken = transcript.trim().split(RegExp(r'\s+')).length;

    var order = const <DrinkOrder>[];
    var wordsSoFar = 0;
    for (final step in SampleOrder.steps) {
      wordsSoFar += step.phrase.split(' ').length;
      if (spoken < wordsSoFar) break;
      order = step.order;
    }
    return order;
  }
}
