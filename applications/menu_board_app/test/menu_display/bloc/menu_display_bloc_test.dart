import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/bloc/menu_display_bloc.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('MenuDisplayBloc', () {
    late MenuRepository menuRepository;

    const group1 = MenuGroup(
      id: 'g1',
      name: 'Espresso',
      description: 'Coffee drinks',
      color: 0xFF000000,
    );

    const item1 = MenuItem(
      id: 'i1',
      name: 'Americano',
      price: 400,
      groupId: 'g1',
    );

    setUp(() {
      menuRepository = _MockMenuRepository();
    });

    test('initial state is MenuDisplayState with initial status', () {
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());
      expect(
        MenuDisplayBloc(menuRepository: menuRepository).state,
        const MenuDisplayState(),
      );
    });

    group('MenuDisplaySubscriptionRequested', () {
      blocTest<MenuDisplayBloc, MenuDisplayState>(
        'emits [loading] before first stream value',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer((_) => const Stream.empty());
          return MenuDisplayBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(const MenuDisplaySubscriptionRequested()),
        expect: () => [
          const MenuDisplayState(status: MenuDisplayStatus.loading),
        ],
      );

      blocTest<MenuDisplayBloc, MenuDisplayState>(
        'emits [loading, success] with groups and items on stream data',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer(
            (_) => Stream.value(
              (
                groups: [group1],
                items: [item1],
                modifierGroups: const <ModifierGroup>[],
              ),
            ),
          );
          return MenuDisplayBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(const MenuDisplaySubscriptionRequested()),
        expect: () => [
          const MenuDisplayState(status: MenuDisplayStatus.loading),
          const MenuDisplayState(
            status: MenuDisplayStatus.success,
            groups: [group1],
            items: [item1],
          ),
        ],
      );

      blocTest<MenuDisplayBloc, MenuDisplayState>(
        'emits [loading, failure] on stream error',
        build: () {
          when(
            () => menuRepository.getMenuGroupsAndItems(),
          ).thenAnswer(
            (_) => Stream.error(Exception('network error')),
          );
          return MenuDisplayBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(const MenuDisplaySubscriptionRequested()),
        expect: () => [
          const MenuDisplayState(status: MenuDisplayStatus.loading),
          const MenuDisplayState(status: MenuDisplayStatus.failure),
        ],
      );
    });
  });
}
