import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_voice_order_app/decisions/decisions.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';

Map<String, Object?> _choice(String name, String choice) {
  return {'type': 'choice', 'name': name, 'choice': choice, 'confidence': 0.9};
}

void main() {
  group('OrderQuestions', () {
    group('build', () {
      test('asks five uniquely named choice questions per slot', () {
        final questions = OrderQuestions.build();

        expect(questions, hasLength(OrderQuestions.maxDrinks * 5));
        expect(
          questions.map((question) => question['name']).toSet(),
          hasLength(questions.length),
        );
        expect(
          questions.every((question) => question['type'] == 'choice'),
          isTrue,
        );
      });

      test('stays within the Decisions API limits', () {
        final questions = OrderQuestions.build();

        // 1-400 questions per request, 2-255 unique choices per question.
        expect(questions.length, inInclusiveRange(1, 400));
        for (final question in questions) {
          final values = (question['choices']! as List<Map<String, String>>)
              .map((choice) => choice['value'])
              .toList();
          expect(values.length, inInclusiveRange(2, 255));
          expect(values.toSet(), hasLength(values.length));
        }
      });

      test('offers every menu drink for a slot', () {
        final drinkQuestion = OrderQuestions.build().firstWhere(
          (question) => question['name'] == 'drink_1',
        );
        final values = (drinkQuestion['choices']! as List<Map<String, String>>)
            .map((choice) => choice['value']);

        expect(values, containsAll(VoiceMenu.drinks.map((drink) => drink.id)));
      });
    });

    group('parse', () {
      test('reads every option the customer asked for', () {
        final orders = OrderQuestions.parse([
          _choice('drink_1', 'latte'),
          _choice('size_1', 'venti'),
          _choice('shots_1', '3'),
          _choice('milk_1', 'oat'),
          _choice('temperature_1', 'iced'),
        ]);

        expect(orders, [
          DrinkOrder(
            drink: VoiceMenu.byId('latte')!,
            size: DrinkSize.venti,
            shots: 3,
            milk: Milk.oat,
            temperature: Temperature.iced,
          ),
        ]);
      });

      test('falls back to the menu defaults for unspecified options', () {
        final orders = OrderQuestions.parse([
          _choice('drink_1', 'cold_brew'),
          _choice('size_1', 'unspecified'),
          _choice('shots_1', 'unspecified'),
          _choice('milk_1', 'unspecified'),
          _choice('temperature_1', 'unspecified'),
        ]);

        expect(orders.single.size, DrinkSize.tall);
        expect(orders.single.shots, 0);
        expect(orders.single.milk, Milk.none);
        expect(orders.single.temperature, Temperature.iced);
      });

      test('reads an explicit request for no milk', () {
        final orders = OrderQuestions.parse([
          _choice('drink_1', 'latte'),
          _choice('milk_1', 'no_milk'),
        ]);

        expect(orders.single.milk, Milk.none);
      });

      test('keeps drinks in slot order and skips empty slots', () {
        final orders = OrderQuestions.parse([
          _choice('drink_3', 'mocha'),
          _choice('drink_1', 'latte'),
          _choice('drink_2', 'none'),
        ]);

        expect(orders.map((order) => order.drink.id), ['latte', 'mocha']);
      });

      test('ignores refusals and answers it does not recognize', () {
        final orders = OrderQuestions.parse([
          {'type': 'refusal', 'name': 'drink_1'},
          _choice('drink_2', 'cappuccino'),
          {'type': 'refusal', 'name': 'size_2'},
          _choice('milk_2', 'goat'),
          {'type': 'predicate', 'name': 'drink_3', 'probability': 0.9},
          'not an answer',
        ]);

        expect(orders, [
          DrinkOrder.withDefaults(VoiceMenu.byId('cappuccino')!),
        ]);
      });

      test('returns an empty order when there are no answers', () {
        expect(OrderQuestions.parse([]), isEmpty);
      });
    });
  });

  group('DrinkOrder', () {
    final latte = VoiceMenu.byId('latte')!;

    test('prices size, milk and extra shots', () {
      final order = DrinkOrder.withDefaults(
        latte,
        size: DrinkSize.venti,
        shots: 4,
        milk: Milk.oat,
      );

      // 525 base + 100 venti + 75 oat + 2 extra shots at 100.
      expect(order.priceCents, 900);
    });

    test('does not discount fewer shots than the default', () {
      expect(
        DrinkOrder.withDefaults(latte, shots: 1).priceCents,
        latte.priceCents,
      );
    });

    test('names and pictures the iced version of a hot drink', () {
      final iced = DrinkOrder.withDefaults(
        latte,
        temperature: Temperature.iced,
      );

      expect(iced.displayName, 'Iced Latte');
      expect(iced.imageUrl, latte.icedImageUrl);
    });

    test('does not prefix a drink that is iced by default', () {
      final coldBrew = DrinkOrder.withDefaults(VoiceMenu.byId('cold_brew')!);

      expect(coldBrew.displayName, 'Cold Brew');
    });
  });
}
