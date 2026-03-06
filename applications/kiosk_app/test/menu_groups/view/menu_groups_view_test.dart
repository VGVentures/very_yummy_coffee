import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_groups/menu_groups.dart';

import '../../helpers/helpers.dart';

class _MockMenuGroupsBloc extends MockBloc<MenuGroupsEvent, MenuGroupsState>
    implements MenuGroupsBloc {}

void main() {
  group('MenuGroupsView', () {
    late MenuGroupsBloc menuGroupsBloc;
    late GoRouter goRouter;

    setUp(() {
      menuGroupsBloc = _MockMenuGroupsBloc();
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: menuGroupsBloc,
        child: const MenuGroupsView(),
      );
    }

    testWidgets('renders loading indicator when loading', (tester) async {
      when(() => menuGroupsBloc.state).thenReturn(const MenuGroupsState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message on failure', (tester) async {
      when(() => menuGroupsBloc.state).thenReturn(
        const MenuGroupsState(status: MenuGroupsStatus.failure),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders category cards on success', (tester) async {
      when(() => menuGroupsBloc.state).thenReturn(
        const MenuGroupsState(
          status: MenuGroupsStatus.success,
          menuGroups: [
            MenuGroup(
              id: '1',
              name: 'Coffee',
              description: 'Hot',
              color: 0xFFC96B45,
            ),
            MenuGroup(
              id: '2',
              name: 'Tea',
              description: 'Warm',
              color: 0xFF5A9E6F,
            ),
          ],
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
    });

    testWidgets('navigates to group on card tap', (tester) async {
      when(() => menuGroupsBloc.state).thenReturn(
        const MenuGroupsState(
          status: MenuGroupsStatus.success,
          menuGroups: [
            MenuGroup(
              id: 'coffee',
              name: 'Coffee',
              description: 'Hot',
              color: 0xFFC96B45,
            ),
          ],
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);
      await tester.tap(find.text('Coffee'));

      verify(() => goRouter.go('/home/menu/coffee')).called(1);
    });
  });
}
