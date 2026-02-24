import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'cart_bloc.mapper.dart';
part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const CartState()) {
    on<CartSubscriptionRequested>(_onSubscriptionRequested);
    on<CartItemQuantityUpdated>(_onItemQuantityUpdated);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    CartSubscriptionRequested event,
    Emitter<CartState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.currentOrderStream,
      onData: (order) =>
          state.copyWith(order: order, status: CartStatus.success),
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
