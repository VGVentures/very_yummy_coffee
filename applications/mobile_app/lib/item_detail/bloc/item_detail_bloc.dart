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
    on<ItemDetailModifierOptionToggled>(_onModifierOptionToggled);
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
      _menuRepository.getMenuGroupsAndItems(),
      onData: (data) {
        final item = data.items
            .where(
              (i) => i.id == event.itemId && i.groupId == event.groupId,
            )
            .firstOrNull;
        if (item == null) {
          return state.copyWith(status: ItemDetailStatus.failure);
        }
        // Initialize modifiers only on first item load.
        if (state.item == null) {
          final applicable = data.modifierGroups.applicableTo(event.groupId);
          final defaults = <String, List<String>>{};
          for (final group in applicable) {
            if (group.defaultOptionId != null) {
              defaults[group.id] = [group.defaultOptionId!];
            }
          }
          return state.copyWith(
            item: item,
            applicableModifierGroups: applicable,
            selectedModifiers: defaults,
            status: ItemDetailStatus.idle,
          );
        }
        return state.copyWith(item: item, status: ItemDetailStatus.idle);
      },
      onError: (_, _) => state.copyWith(status: ItemDetailStatus.failure),
    );
  }

  void _onModifierOptionToggled(
    ItemDetailModifierOptionToggled event,
    Emitter<ItemDetailState> emit,
  ) {
    final group = state.applicableModifierGroups.firstWhere(
      (g) => g.id == event.groupId,
    );
    final newMap = Map<String, List<String>>.from(state.selectedModifiers);

    if (group.selectionMode == SelectionMode.single) {
      newMap[event.groupId] = [event.optionId];
    } else {
      final current = List<String>.from(newMap[event.groupId] ?? []);
      if (current.contains(event.optionId)) {
        current.remove(event.optionId);
      } else {
        current.add(event.optionId);
      }
      newMap[event.groupId] = current;
    }
    emit(state.copyWith(selectedModifiers: newMap));
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
    final item = state.item;
    if (item == null || !state.canAddToCart) {
      emit(state.copyWith(status: ItemDetailStatus.failure));
      return;
    }
    emit(state.copyWith(status: ItemDetailStatus.adding));
    try {
      final modifiers = _buildSelectedModifiers();
      await _orderRepository.addItemToCurrentOrder(
        itemName: item.name,
        itemPrice: item.price,
        quantity: state.quantity,
        menuItemId: item.id,
        modifiers: modifiers,
      );
      emit(state.copyWith(status: ItemDetailStatus.added));
    } on Exception catch (_) {
      emit(state.copyWith(status: ItemDetailStatus.failure));
    }
  }

  List<SelectedModifier> _buildSelectedModifiers() {
    final modifiers = <SelectedModifier>[];
    for (final group in state.applicableModifierGroups) {
      final selectedIds = state.selectedModifiers[group.id] ?? [];
      if (selectedIds.isEmpty) continue;
      final selectedOptions = group.options
          .where((o) => selectedIds.contains(o.id))
          .map(
            (o) => SelectedOption(
              id: o.id,
              name: o.name,
              priceDeltaCents: o.priceDeltaCents,
            ),
          )
          .toList();
      modifiers.add(
        SelectedModifier(
          modifierGroupId: group.id,
          modifierGroupName: group.name,
          options: selectedOptions,
        ),
      );
    }
    return modifiers;
  }
}
