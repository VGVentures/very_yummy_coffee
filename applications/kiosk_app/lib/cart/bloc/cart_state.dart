part of 'cart_bloc.dart';

@MappableEnum()
enum CartStatus { loading, success, failure }

@MappableClass()
class CartState with CartStateMappable {
  const CartState({
    this.order,
    this.status = CartStatus.loading,
  });

  final Order? order;
  final CartStatus status;
}
