import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_groups/menu_groups.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('MenuGroupsBloc', () {
    late MenuRepository menuRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
    });

    test('initial state is MenuGroupsState', () {
      when(
        () => menuRepository.getMenuGroups(),
      ).thenAnswer((_) => const Stream.empty());
      expect(
        MenuGroupsBloc(menuRepository: menuRepository).state,
        const MenuGroupsState(),
      );
    });

    group('MenuGroupsSubscriptionRequested', () {
      final groups = [
        const MenuGroup(
          id: '1',
          name: 'Coffee',
          description: 'Hot coffee',
          color: 0xFFC96B45,
        ),
      ];

      blocTest<MenuGroupsBloc, MenuGroupsState>(
        'emits [loading, success] on successful subscription',
        build: () {
          when(
            () => menuRepository.getMenuGroups(),
          ).thenAnswer((_) => Stream.value(groups));
          return MenuGroupsBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(const MenuGroupsSubscriptionRequested()),
        expect: () => [
          const MenuGroupsState(status: MenuGroupsStatus.loading),
          MenuGroupsState(
            status: MenuGroupsStatus.success,
            menuGroups: groups,
          ),
        ],
      );

      blocTest<MenuGroupsBloc, MenuGroupsState>(
        'emits [loading, failure] on error',
        build: () {
          when(
            () => menuRepository.getMenuGroups(),
          ).thenAnswer((_) => Stream.error(Exception('error')));
          return MenuGroupsBloc(menuRepository: menuRepository);
        },
        act: (bloc) => bloc.add(const MenuGroupsSubscriptionRequested()),
        expect: () => [
          const MenuGroupsState(status: MenuGroupsStatus.loading),
          const MenuGroupsState(status: MenuGroupsStatus.failure),
        ],
      );
    });
  });
}
