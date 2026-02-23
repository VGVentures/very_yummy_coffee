import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';

part 'item_detail_bloc.mapper.dart';
part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  ItemDetailBloc({
    required MenuRepository menuRepository,
    required OrderRepository orderRepository,
  }) : _menuRepository = menuRepository,
       _orderRepository = orderRepository,
       super(const ItemDetailState()) {
    on<ItemDetailSubscriptionRequested>(_onSubscriptionRequested);
    on<ItemDetailSizeSelected>(_onSizeSelected);
    on<ItemDetailMilkSelected>(_onMilkSelected);
    on<ItemDetailExtraToggled>(_onExtraToggled);
    on<ItemDetailQuantityIncremented>(_onQuantityIncremented);
    on<ItemDetailQuantityDecremented>(_onQuantityDecremented);
    on<ItemDetailAddToCartRequested>(_onAddToCartRequested);
  }

  final MenuRepository _menuRepository;
  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    ItemDetailSubscriptionRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    await emit.forEach(
      _menuRepository.getMenuItem(event.groupId, event.itemId),
      onData: (item) {
        if (item == null) {
          return state.copyWith(status: ItemDetailStatus.failure);
        }
        return state.copyWith(item: item, status: ItemDetailStatus.idle);
      },
      onError: (_, _) => state.copyWith(status: ItemDetailStatus.failure),
    );
  }

  void _onSizeSelected(
    ItemDetailSizeSelected event,
    Emitter<ItemDetailState> emit,
  ) {
    emit(state.copyWith(selectedSize: event.size));
  }

  void _onMilkSelected(
    ItemDetailMilkSelected event,
    Emitter<ItemDetailState> emit,
  ) {
    emit(state.copyWith(selectedMilk: event.milk));
  }

  void _onExtraToggled(
    ItemDetailExtraToggled event,
    Emitter<ItemDetailState> emit,
  ) {
    final extras = List<DrinkExtra>.from(state.selectedExtras);
    if (extras.contains(event.extra)) {
      extras.remove(event.extra);
    } else {
      extras.add(event.extra);
    }
    emit(state.copyWith(selectedExtras: extras));
  }

  void _onQuantityIncremented(
    ItemDetailQuantityIncremented event,
    Emitter<ItemDetailState> emit,
  ) {
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void _onQuantityDecremented(
    ItemDetailQuantityDecremented event,
    Emitter<ItemDetailState> emit,
  ) {
    if (state.quantity <= 1) return;
    emit(state.copyWith(quantity: state.quantity - 1));
  }

  Future<void> _onAddToCartRequested(
    ItemDetailAddToCartRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    emit(state.copyWith(status: ItemDetailStatus.adding));
    try {
      if (_orderRepository.currentOrderId == null) {
        await _orderRepository.createOrder();
      }
      for (var i = 0; i < state.quantity; i++) {
        _orderRepository.addItemToCurrentOrder(
          itemName: state.item!.name,
          itemPrice: state.item!.price,
        );
      }
      emit(state.copyWith(status: ItemDetailStatus.added));
    } on Exception catch (_) {
      emit(state.copyWith(status: ItemDetailStatus.failure));
    }
  }
}
