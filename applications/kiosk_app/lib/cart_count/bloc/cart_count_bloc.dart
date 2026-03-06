import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'cart_count_bloc.mapper.dart';
part 'cart_count_event.dart';
part 'cart_count_state.dart';

class CartCountBloc extends Bloc<CartCountEvent, CartCountState> {
  CartCountBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const CartCountState()) {
    on<CartCountSubscriptionRequested>(_onSubscriptionRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    CartCountSubscriptionRequested event,
    Emitter<CartCountState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.currentOrderStream,
      onData: (order) => CartCountState(
        itemCount: order?.items.fold<int>(0, (sum, i) => sum + i.quantity) ?? 0,
      ),
      onError: (_, _) => const CartCountState(),
    );
  }
}
