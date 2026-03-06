part of 'cart_count_bloc.dart';

@MappableClass()
class CartCountState with CartCountStateMappable {
  const CartCountState({this.itemCount = 0});

  final int itemCount;
}
