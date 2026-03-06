import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'menu_items_bloc.mapper.dart';
part 'menu_items_event.dart';
part 'menu_items_state.dart';

class MenuItemsBloc extends Bloc<MenuItemsEvent, MenuItemsState> {
  MenuItemsBloc({
    required MenuRepository menuRepository,
    required String groupId,
  }) : _menuRepository = menuRepository,
       _groupId = groupId,
       super(const MenuItemsState()) {
    on<MenuItemsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final MenuRepository _menuRepository;
  final String _groupId;

  Future<void> _onSubscriptionRequested(
    MenuItemsSubscriptionRequested event,
    Emitter<MenuItemsState> emit,
  ) async {
    emit(state.copyWith(status: MenuItemsStatus.loading));
    await emit.forEach(
      Rx.combineLatest2(
        _menuRepository.getMenuGroups(),
        _menuRepository.getMenuItems(_groupId),
        (groups, items) => (
          groupName:
              groups.where((g) => g.id == _groupId).firstOrNull?.name ?? '',
          menuItems: items,
        ),
      ),
      onData: (data) => state.copyWith(
        status: MenuItemsStatus.success,
        menuItems: data.menuItems,
        groupName: data.groupName,
      ),
      onError: (_, _) => state.copyWith(status: MenuItemsStatus.failure),
    );
  }
}
