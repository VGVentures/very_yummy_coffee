import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:meta/meta.dart';

part 'stock_management_bloc.mapper.dart';
part 'stock_management_event.dart';
part 'stock_management_state.dart';

class StockManagementBloc
    extends Bloc<StockManagementEvent, StockManagementState> {
  StockManagementBloc({required MenuRepository menuRepository})
    : _menuRepository = menuRepository,
      super(const StockManagementState()) {
    on<StockManagementSubscriptionRequested>(_onSubscriptionRequested);
    on<StockManagementItemToggled>(_onItemToggled);
  }

  final MenuRepository _menuRepository;

  Future<void> _onSubscriptionRequested(
    StockManagementSubscriptionRequested event,
    Emitter<StockManagementState> emit,
  ) async {
    emit(state.copyWith(status: StockManagementStatus.loading));
    await emit.forEach(
      _menuRepository.getMenuGroupsAndItems(),
      onData: (data) => state.copyWith(
        status: StockManagementStatus.success,
        groups: data.groups,
        items: data.items,
      ),
      onError: (_, _) => state.copyWith(
        status: StockManagementStatus.failure,
      ),
    );
  }

  void _onItemToggled(
    StockManagementItemToggled event,
    Emitter<StockManagementState> emit,
  ) {
    try {
      _menuRepository.setItemAvailability(
        event.itemId,
        available: event.available,
      );
    } on Exception {
      emit(state.copyWith(status: StockManagementStatus.failure));
    }
  }
}
