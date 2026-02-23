part of 'item_detail_bloc.dart';

@MappableEnum()
enum DrinkSize {
  small,
  medium,
  large
  ;

  String get shortLabel => switch (this) {
    DrinkSize.small => 'S',
    DrinkSize.medium => 'M',
    DrinkSize.large => 'L',
  };

  String get label => switch (this) {
    DrinkSize.small => 'Small',
    DrinkSize.medium => 'Medium',
    DrinkSize.large => 'Large',
  };
}

@MappableEnum()
enum MilkOption {
  whole,
  oat,
  almond,
  soy
  ;

  String get label => switch (this) {
    MilkOption.whole => 'Whole Milk',
    MilkOption.oat => 'Oat Milk',
    MilkOption.almond => 'Almond Milk',
    MilkOption.soy => 'Soy Milk',
  };
}

@MappableEnum()
enum DrinkExtra {
  extraShot,
  vanillaSyrup,
  caramel
  ;

  String get label => switch (this) {
    DrinkExtra.extraShot => 'Extra Shot',
    DrinkExtra.vanillaSyrup => 'Vanilla Syrup',
    DrinkExtra.caramel => 'Caramel',
  };
}

@MappableEnum()
enum ItemDetailStatus { loading, idle, adding, added, failure }

@MappableClass()
class ItemDetailState with ItemDetailStateMappable {
  const ItemDetailState({
    this.item,
    this.selectedSize = DrinkSize.medium,
    this.selectedMilk = MilkOption.whole,
    this.selectedExtras = const [],
    this.quantity = 1,
    this.status = ItemDetailStatus.loading,
  });

  final MenuItem? item;
  final DrinkSize selectedSize;
  final MilkOption selectedMilk;
  final List<DrinkExtra> selectedExtras;
  final int quantity;
  final ItemDetailStatus status;

  int get totalPrice => (item?.price ?? 0) * quantity;
}
