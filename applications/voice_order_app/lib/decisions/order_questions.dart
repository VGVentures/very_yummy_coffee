import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';

/// Builds the Decisions API questions for an order and reads the answers.
///
/// The Decisions API only returns typed answers (a choice, a probability or
/// a score), never a list. An order is therefore modelled as a fixed number
/// of numbered slots, each described by five `choice` questions: which drink
/// is in the slot, and its size, shots, milk and temperature.
abstract final class OrderQuestions {
  /// The most drinks one order can hold.
  static const maxDrinks = 6;

  static const _none = 'none';
  static const _unspecified = 'unspecified';

  /// Shared rules sent ahead of the transcript on every request.
  static const instructions =
      'You are reading a live, partial speech-to-text transcript of a '
      'customer ordering drinks at Very Yummy Coffee. Work out what the '
      'order is right now.\n'
      '- Number the drinks in the order the customer first asked for them: '
      'drink 1, drink 2, and so on.\n'
      '- Apply every later correction or change to the drink it refers to '
      '("actually", "the other one", "that one", "the small one").\n'
      '- "Two lattes" or "one more" means two separate drinks.\n'
      '- If the customer removes a drink, the drinks after it move up.\n'
      '- The transcript may stop mid-sentence. Only count what was said.';

  /// The questions for every slot, in a stable order.
  static List<Map<String, Object?>> build() {
    return [
      for (var slot = 1; slot <= maxDrinks; slot++) ..._slotQuestions(slot),
    ];
  }

  /// Reads the `answers` array of a Decisions API response.
  ///
  /// Slots answered `none`, refused or missing are skipped, so a refusal on
  /// one question never empties the rest of the order.
  static List<DrinkOrder> parse(List<Object?> answers) {
    final choices = <String, String>{};
    for (final answer in answers) {
      if (answer is! Map) continue;
      final name = answer['name'];
      final choice = answer['choice'];
      if (answer['type'] == 'choice' && name is String && choice is String) {
        choices[name] = choice;
      }
    }

    final orders = <DrinkOrder>[];
    for (var slot = 1; slot <= maxDrinks; slot++) {
      final drink = VoiceMenu.byId(choices['drink_$slot'] ?? _none);
      if (drink == null) continue;
      orders.add(
        DrinkOrder.withDefaults(
          drink,
          size: _sizes[choices['size_$slot']],
          shots: int.tryParse(choices['shots_$slot'] ?? ''),
          milk: _milks[choices['milk_$slot']],
          temperature: _temperatures[choices['temperature_$slot']],
        ),
      );
    }
    return orders;
  }

  static List<Map<String, Object?>> _slotQuestions(int slot) {
    return [
      _choice(
        name: 'drink_$slot',
        instructions:
            'Which menu item is drink $slot in the current order? Answer '
            '"$_none" if the order has fewer than $slot drinks.',
        choices: [
          for (final drink in VoiceMenu.drinks) _option(drink.id, drink.name),
          _option(_none, 'There is no drink $slot'),
        ],
      ),
      _choice(
        name: 'size_$slot',
        instructions: 'What size did the customer ask for drink $slot?',
        choices: [
          _option('short', 'Short, extra small, 8 oz'),
          _option('tall', 'Tall, small, 12 oz'),
          _option('grande', 'Grande, medium, 16 oz'),
          _option('venti', 'Venti, large, 20 oz'),
          _noAnswer(slot, 'No size was mentioned'),
        ],
      ),
      _choice(
        name: 'shots_$slot',
        instructions:
            'How many espresso shots did the customer ask for in drink '
            '$slot? "An extra shot" does not give a total.',
        choices: [
          for (var shots = 1; shots <= VoiceMenu.maxShots; shots++)
            _option('$shots', '$shots espresso shot${shots == 1 ? '' : 's'}'),
          _noAnswer(slot, 'No total number of shots was mentioned'),
        ],
      ),
      _choice(
        name: 'milk_$slot',
        instructions: 'Which milk did the customer ask for in drink $slot?',
        choices: [
          _option('whole', 'Whole milk'),
          _option('two_percent', '2% milk'),
          _option('oat', 'Oat milk'),
          _option('almond', 'Almond milk'),
          _option('soy', 'Soy milk'),
          _option('no_milk', 'The customer asked for no milk, or black'),
          _noAnswer(slot, 'No milk was mentioned'),
        ],
      ),
      _choice(
        name: 'temperature_$slot',
        instructions: 'Did the customer ask for drink $slot hot or iced?',
        choices: [
          _option('hot', 'Hot'),
          _option('iced', 'Iced, cold, or over ice'),
          _noAnswer(slot, 'Neither was mentioned'),
        ],
      ),
    ];
  }

  static Map<String, Object?> _choice({
    required String name,
    required String instructions,
    required List<Map<String, String>> choices,
  }) {
    return {
      'type': 'choice',
      'name': name,
      'instructions': instructions,
      'choices': choices,
    };
  }

  static Map<String, String> _option(String value, String description) {
    return {'value': value, 'description': description};
  }

  static Map<String, String> _noAnswer(int slot, String description) {
    return _option(_unspecified, '$description, or there is no drink $slot');
  }

  static const Map<String, DrinkSize> _sizes = {
    'short': DrinkSize.short,
    'tall': DrinkSize.tall,
    'grande': DrinkSize.grande,
    'venti': DrinkSize.venti,
  };

  static const Map<String, Milk> _milks = {
    'whole': Milk.whole,
    'two_percent': Milk.twoPercent,
    'oat': Milk.oat,
    'almond': Milk.almond,
    'soy': Milk.soy,
    'no_milk': Milk.none,
  };

  static const Map<String, Temperature> _temperatures = {
    'hot': Temperature.hot,
    'iced': Temperature.iced,
  };
}
