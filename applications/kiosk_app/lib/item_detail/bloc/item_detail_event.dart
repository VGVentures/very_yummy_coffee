part of 'item_detail_bloc.dart';

sealed class ItemDetailEvent {
  const ItemDetailEvent();
}

class ItemDetailSubscriptionRequested extends ItemDetailEvent {
  const ItemDetailSubscriptionRequested(this.groupId, this.itemId);

  final String groupId;
  final String itemId;
}

class ItemDetailModifierOptionToggled extends ItemDetailEvent {
  const ItemDetailModifierOptionToggled({
    required this.groupId,
    required this.optionId,
  });

  final String groupId;
  final String optionId;
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
