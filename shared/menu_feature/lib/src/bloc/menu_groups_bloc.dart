import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:menu_repository/menu_repository.dart';

part 'menu_groups_bloc.mapper.dart';
part 'menu_groups_event.dart';
part 'menu_groups_state.dart';

class MenuGroupsBloc extends Bloc<MenuGroupsEvent, MenuGroupsState> {
  MenuGroupsBloc({required MenuRepository menuRepository})
    : _menuRepository = menuRepository,
      super(const MenuGroupsState()) {
    on<MenuGroupsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final MenuRepository _menuRepository;

  Future<void> _onSubscriptionRequested(
    MenuGroupsSubscriptionRequested event,
    Emitter<MenuGroupsState> emit,
  ) async {
    emit(state.copyWith(status: MenuGroupsStatus.loading));
    await emit.forEach<List<MenuGroup>>(
      _menuRepository.getMenuGroups(),
      onData: (menuGroups) => state.copyWith(
        status: MenuGroupsStatus.success,
        menuGroups: menuGroups,
      ),
      onError: (_, _) => state.copyWith(status: MenuGroupsStatus.failure),
    );
  }
}
