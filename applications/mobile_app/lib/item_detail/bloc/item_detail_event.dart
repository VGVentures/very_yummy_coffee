part of 'item_detail_bloc.dart';

sealed class ItemDetailEvent {
  const ItemDetailEvent();
}

class ItemDetailSubscriptionRequested extends ItemDetailEvent {
  const ItemDetailSubscriptionRequested(this.groupId, this.itemId);

  final String groupId;
  final String itemId;
}

class ItemDetailSizeSelected extends ItemDetailEvent {
  const ItemDetailSizeSelected(this.size);

  final DrinkSize size;
}

class ItemDetailMilkSelected extends ItemDetailEvent {
  const ItemDetailMilkSelected(this.milk);

  final MilkOption milk;
}

class ItemDetailExtraToggled extends ItemDetailEvent {
  const ItemDetailExtraToggled(this.extra);

  final DrinkExtra extra;
}

class ItemDetailQuantityIncremented extends ItemDetailEvent {
  const ItemDetailQuantityIncremented();
}

class ItemDetailQuantityDecremented extends ItemDetailEvent {
  const ItemDetailQuantityDecremented();
}

class ItemDetailAddToCartRequested extends ItemDetailEvent {
  const ItemDetailAddToCartRequested();
}
