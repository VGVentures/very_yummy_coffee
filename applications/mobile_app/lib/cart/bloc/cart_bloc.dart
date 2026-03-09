import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'cart_bloc.mapper.dart';
part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required OrderRepository orderRepository,
    required MenuRepository menuRepository,
  }) : _orderRepository = orderRepository,
       _menuRepository = menuRepository,
       super(const CartState()) {
    on<CartSubscriptionRequested>(_onSubscriptionRequested);
    on<CartItemQuantityUpdated>(_onItemQuantityUpdated);
  }

  final OrderRepository _orderRepository;
  final MenuRepository _menuRepository;

  Future<void> _onSubscriptionRequested(
    CartSubscriptionRequested event,
    Emitter<CartState> emit,
  ) async {
    await emit.forEach(
      Rx.combineLatest2(
        _orderRepository.currentOrderStream,
        _menuRepository.getMenuGroupsAndItems(),
        (order, menuData) {
          final unavailableMenuItemIds = <String>{
            for (final item in menuData.items)
              if (!item.available) item.id,
          };
          final unavailableLineItemIds = <String>[
            if (order != null)
              for (final lineItem in order.items)
                if (lineItem.menuItemId != null &&
                    unavailableMenuItemIds.contains(lineItem.menuItemId))
                  lineItem.id,
          ];
          return (order: order, unavailableLineItemIds: unavailableLineItemIds);
        },
      ),
      onData: (data) => state.copyWith(
        order: data.order,
        status: CartStatus.success,
        unavailableLineItemIds: data.unavailableLineItemIds,
      ),
      onError: (_, _) => state.copyWith(status: CartStatus.failure),
    );
  }

  Future<void> _onItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      _orderRepository.updateItemQuantity(event.lineItemId, event.quantity);
    } on Exception catch (_) {
      emit(state.copyWith(status: CartStatus.failure));
    }
  }
}
