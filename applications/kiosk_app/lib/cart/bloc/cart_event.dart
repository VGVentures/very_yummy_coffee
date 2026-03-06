part of 'cart_bloc.dart';

@MappableClass()
sealed class CartEvent with CartEventMappable {
  const CartEvent();
}

@MappableClass()
class CartSubscriptionRequested extends CartEvent
    with CartSubscriptionRequestedMappable {
  const CartSubscriptionRequested();
}

@MappableClass()
class CartItemQuantityUpdated extends CartEvent
    with CartItemQuantityUpdatedMappable {
  const CartItemQuantityUpdated({
    required this.lineItemId,
    required this.quantity,
  });

  final String lineItemId;

  /// A quantity of 0 removes the item.
  final int quantity;
}
