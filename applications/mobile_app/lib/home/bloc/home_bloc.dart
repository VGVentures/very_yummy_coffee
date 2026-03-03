import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:order_repository/order_repository.dart';

part 'home_bloc.mapper.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const HomeState()) {
    on<HomeSubscriptionRequested>(_onSubscriptionRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    HomeSubscriptionRequested event,
    Emitter<HomeState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.ordersStream,
      onData: (orders) {
        final active = orders.orders
            .where(
              (o) =>
                  o.status != OrderStatus.completed &&
                  o.status != OrderStatus.cancelled,
            )
            .toList();
        return state.copyWith(orders: active, status: HomeStatus.success);
      },
      onError: (_, _) => state.copyWith(status: HomeStatus.failure),
    );
  }
}
