part of 'item_detail_bloc.dart';

@MappableEnum()
enum DrinkSize { small, medium, large }

@MappableEnum()
enum MilkOption { whole, oat, almond, soy }

@MappableEnum()
enum DrinkExtra { extraShot, vanillaSyrup, caramel }

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
