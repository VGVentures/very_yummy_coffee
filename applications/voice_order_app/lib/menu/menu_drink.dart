import 'package:equatable/equatable.dart';

/// Cup sizes, matching the `mg-size` modifier group in `api/fixtures/menu.json`.
enum DrinkSize {
  short('Short', 0),
  tall('Tall', 0),
  grande('Grande', 50),
  venti('Venti', 100)
  ;

  const DrinkSize(this.label, this.priceDeltaCents);

  final String label;
  final int priceDeltaCents;
}

/// Milk options, matching the `mg-milk` modifier group plus [none].
enum Milk {
  none('No milk', 0),
  whole('Whole milk', 0),
  twoPercent('2% milk', 0),
  oat('Oat milk', 75),
  almond('Almond milk', 75),
  soy('Soy milk', 75)
  ;

  const Milk(this.label, this.priceDeltaCents);

  final String label;
  final int priceDeltaCents;
}

/// Temperature options, matching the `mg-temp` modifier group.
enum Temperature {
  hot('Hot'),
  iced('Iced')
  ;

  const Temperature(this.label);

  final String label;
}

/// A drink that can be ordered by voice.
class MenuDrink extends Equatable {
  const MenuDrink({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.imageUrl,
    this.icedImageUrl,
    this.defaultShots = 0,
    this.defaultMilk = Milk.none,
    this.defaultTemperature = Temperature.hot,
  });

  /// Stable identifier, also used as the choice value sent to the model.
  final String id;
  final String name;
  final int priceCents;
  final String imageUrl;

  /// Photo to show when the drink is iced, when one exists.
  final String? icedImageUrl;
  final int defaultShots;
  final Milk defaultMilk;
  final Temperature defaultTemperature;

  @override
  List<Object?> get props => [id];
}
