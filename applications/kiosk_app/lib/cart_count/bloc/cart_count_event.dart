part of 'cart_count_bloc.dart';

@MappableClass()
sealed class CartCountEvent {
  const CartCountEvent();
}

@MappableClass()
class CartCountSubscriptionRequested extends CartCountEvent
    with CartCountSubscriptionRequestedMappable {
  const CartCountSubscriptionRequested();
}
