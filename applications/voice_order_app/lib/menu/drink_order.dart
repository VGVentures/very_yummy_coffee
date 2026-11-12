import 'package:equatable/equatable.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu_drink.dart';

/// One drink in the customer's order, with every option resolved.
class DrinkOrder extends Equatable {
  const DrinkOrder({
    required this.drink,
    required this.size,
    required this.shots,
    required this.milk,
    required this.temperature,
  });

  /// A [drink] with the menu defaults, overridden by whatever the customer
  /// actually asked for.
  factory DrinkOrder.withDefaults(
    MenuDrink drink, {
    DrinkSize? size,
    int? shots,
    Milk? milk,
    Temperature? temperature,
  }) {
    return DrinkOrder(
      drink: drink,
      size: size ?? defaultSize,
      shots: shots ?? drink.defaultShots,
      milk: milk ?? drink.defaultMilk,
      temperature: temperature ?? drink.defaultTemperature,
    );
  }

  /// Same default as the `mg-size` modifier group.
  static const DrinkSize defaultSize = DrinkSize.tall;

  /// Price of each espresso shot beyond the drink's default ("Extra Shot").
  static const extraShotCents = 100;

  final MenuDrink drink;
  final DrinkSize size;
  final int shots;
  final Milk milk;
  final Temperature temperature;

  /// "Iced Latte" when a normally hot drink is ordered iced.
  String get displayName {
    final isIcedVariant =
        temperature == Temperature.iced &&
        drink.defaultTemperature != Temperature.iced;
    return isIcedVariant ? 'Iced ${drink.name}' : drink.name;
  }

  String get imageUrl {
    if (temperature == Temperature.iced) {
      return drink.icedImageUrl ?? drink.imageUrl;
    }
    return drink.imageUrl;
  }

  int get priceCents {
    final extraShots = shots > drink.defaultShots
        ? shots - drink.defaultShots
        : 0;
    return drink.priceCents +
        size.priceDeltaCents +
        milk.priceDeltaCents +
        extraShots * extraShotCents;
  }

  @override
  List<Object?> get props => [drink, size, shots, milk, temperature];
}
