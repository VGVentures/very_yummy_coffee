import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'menu_bloc.mapper.dart';
part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc({
    required MenuRepository menuRepository,
    required OrderRepository orderRepository,
  }) : _menuRepository = menuRepository,
       _orderRepository = orderRepository,
       super(const MenuState()) {
    on<MenuSubscriptionRequested>(_onSubscriptionRequested);
    on<MenuCategorySelected>(_onCategorySelected);
    on<MenuItemAdded>(_onItemAdded);
  }

  final MenuRepository _menuRepository;
  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    MenuSubscriptionRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    await emit.forEach(
      _menuRepository.getMenuGroupsAndItems(),
      onData: (data) => state.copyWith(
        status: MenuStatus.success,
        groups: data.groups,
        allItems: data.items,
      ),
      onError: (_, _) => state.copyWith(status: MenuStatus.failure),
    );
  }

  void _onCategorySelected(
    MenuCategorySelected event,
    Emitter<MenuState> emit,
  ) {
    emit(state.copyWith(selectedGroupId: event.groupId));
  }

  void _onItemAdded(MenuItemAdded event, Emitter<MenuState> emit) {
    if (!event.item.available) return;
    _orderRepository.addItemToCurrentOrder(
      itemName: event.item.name,
      itemPrice: event.item.price,
      options: '',
      quantity: 1,
    );
  }
}
