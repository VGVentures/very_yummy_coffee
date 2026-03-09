part of 'cart_bloc.dart';

@MappableEnum()
enum CartStatus { loading, success, failure }

@MappableClass()
class CartState with CartStateMappable {
  const CartState({
    this.order,
    this.status = CartStatus.loading,
    this.unavailableLineItemIds = const [],
  });

  final Order? order;
  final CartStatus status;

  /// IDs of line items whose `menuItemId` maps to an unavailable menu item.
  final List<String> unavailableLineItemIds;

  bool get hasUnavailableItems => unavailableLineItemIds.isNotEmpty;
}
