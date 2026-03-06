import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_groups/menu_groups.dart';
import 'package:very_yummy_coffee_kiosk_app/menu_items/menu_items.dart';

import '../../helpers/helpers.dart';

class _MockMenuItemsBloc extends MockBloc<MenuItemsEvent, MenuItemsState>
    implements MenuItemsBloc {}

class _MockMenuGroupsBloc extends MockBloc<MenuGroupsEvent, MenuGroupsState>
    implements MenuGroupsBloc {}

void main() {
  group('MenuItemsView', () {
    late MenuItemsBloc menuItemsBloc;
    late MenuGroupsBloc menuGroupsBloc;
    late GoRouter goRouter;
    const groupId = 'coffee';

    setUp(() {
      menuItemsBloc = _MockMenuItemsBloc();
      menuGroupsBloc = _MockMenuGroupsBloc();
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
      when(() => menuGroupsBloc.state).thenReturn(
        const MenuGroupsState(
          status: MenuGroupsStatus.success,
          menuGroups: [
            MenuGroup(
              id: groupId,
              name: 'Coffee',
              description: 'Hot',
              color: 0xFFC96B45,
            ),
          ],
        ),
      );
    });

    Widget buildSubject() {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: menuItemsBloc),
          BlocProvider.value(value: menuGroupsBloc),
        ],
        child: const MenuItemsView(groupId: groupId),
      );
    }

    testWidgets('renders loading indicator when loading', (tester) async {
      when(() => menuItemsBloc.state).thenReturn(const MenuItemsState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error on failure', (tester) async {
      when(() => menuItemsBloc.state).thenReturn(
        const MenuItemsState(status: MenuItemsStatus.failure),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders item grid on success', (tester) async {
      when(() => menuItemsBloc.state).thenReturn(
        const MenuItemsState(
          status: MenuItemsStatus.success,
          menuItems: [
            MenuItem(id: '1', name: 'Latte', price: 500, groupId: groupId),
            MenuItem(id: '2', name: 'Mocha', price: 600, groupId: groupId),
          ],
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Mocha'), findsOneWidget);
    });

    testWidgets('shows unavailable overlay for unavailable items', (
      tester,
    ) async {
      when(() => menuItemsBloc.state).thenReturn(
        const MenuItemsState(
          status: MenuItemsStatus.success,
          menuItems: [
            MenuItem(
              id: '1',
              name: 'Latte',
              price: 500,
              groupId: groupId,
              available: false,
            ),
          ],
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Latte'), findsOneWidget);
      // Unavailable overlay is a ColoredBox on top
      expect(find.byType(ColoredBox), findsWidgets);
    });
  });
}
