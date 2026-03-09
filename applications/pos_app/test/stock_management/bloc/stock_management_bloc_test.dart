import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/bloc/stock_management_bloc.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  const tGroup = MenuGroup(
    id: 'g1',
    name: 'Espresso',
    description: 'Espresso drinks',
    color: 0xFF795548,
  );
  const tItem = MenuItem(
    id: '101',
    groupId: 'g1',
    name: 'Latte',
    price: 550,
  );
  const tUnavailableItem = MenuItem(
    id: '102',
    groupId: 'g1',
    name: 'Mocha',
    price: 600,
    available: false,
  );

  group('StockManagementBloc', () {
    late MenuRepository menuRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
    });

    test('initial state has initial status', () {
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());

      expect(
        StockManagementBloc(menuRepository: menuRepository).state,
        const StockManagementState(),
      );
    });

    group('StockManagementSubscriptionRequested', () {
      blocTest<StockManagementBloc, StockManagementState>(
        'emits [loading, success] when data arrives',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.value(
              (
                groups: [tGroup],
                items: [tItem, tUnavailableItem],
                modifierGroups: const <ModifierGroup>[],
              ),
            ),
          );
          return StockManagementBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(const StockManagementSubscriptionRequested()),
        expect: () => [
          const StockManagementState(status: StockManagementStatus.loading),
          StockManagementState(
            status: StockManagementStatus.success,
            groups: const [tGroup],
            items: const [tItem, tUnavailableItem],
          ),
        ],
      );

      blocTest<StockManagementBloc, StockManagementState>(
        'emits [loading, failure] on error',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => Stream.error(Exception('fail')),
          );
          return StockManagementBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(const StockManagementSubscriptionRequested()),
        expect: () => [
          const StockManagementState(status: StockManagementStatus.loading),
          const StockManagementState(
            status: StockManagementStatus.failure,
          ),
        ],
      );
    });

    group('StockManagementItemToggled', () {
      blocTest<StockManagementBloc, StockManagementState>(
        'calls setItemAvailability on menu repository',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          return StockManagementBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(
          const StockManagementItemToggled(
            itemId: '101',
            available: false,
          ),
        ),
        verify: (_) {
          verify(
            () => menuRepository.setItemAvailability(
              '101',
              available: false,
            ),
          ).called(1);
        },
      );

      blocTest<StockManagementBloc, StockManagementState>(
        'emits failure when setItemAvailability throws',
        build: () {
          when(() => menuRepository.getMenuGroupsAndItems()).thenAnswer(
            (_) => const Stream.empty(),
          );
          when(
            () => menuRepository.setItemAvailability(
              any(),
              available: any(named: 'available'),
            ),
          ).thenThrow(Exception('network error'));
          return StockManagementBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(
          const StockManagementItemToggled(
            itemId: '101',
            available: false,
          ),
        ),
        expect: () => [
          const StockManagementState(
            status: StockManagementStatus.failure,
          ),
        ],
      );
    });
  });

  group('StockManagementState', () {
    test('itemsForGroup returns items matching groupId', () {
      const state = StockManagementState(
        items: [tItem, tUnavailableItem],
      );
      expect(state.itemsForGroup('g1'), [tItem, tUnavailableItem]);
      expect(state.itemsForGroup('unknown'), isEmpty);
    });
  });
}
