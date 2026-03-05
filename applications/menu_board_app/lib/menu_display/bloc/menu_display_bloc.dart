import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:menu_repository/menu_repository.dart';

part 'menu_display_bloc.mapper.dart';
part 'menu_display_event.dart';
part 'menu_display_state.dart';

class MenuDisplayBloc extends Bloc<MenuDisplayEvent, MenuDisplayState> {
  MenuDisplayBloc({required MenuRepository menuRepository})
    : _menuRepository = menuRepository,
      super(const MenuDisplayState()) {
    on<MenuDisplaySubscriptionRequested>(_onSubscriptionRequested);
  }

  final MenuRepository _menuRepository;

  Future<void> _onSubscriptionRequested(
    MenuDisplaySubscriptionRequested event,
    Emitter<MenuDisplayState> emit,
  ) async {
    emit(state.copyWith(status: MenuDisplayStatus.loading));
    await emit.forEach(
      _menuRepository.getMenuGroupsAndItems(),
      onData: (data) => state.copyWith(
        status: MenuDisplayStatus.success,
        groups: data.groups,
        items: data.items,
      ),
      onError: (_, _) => state.copyWith(status: MenuDisplayStatus.failure),
    );
  }
}
