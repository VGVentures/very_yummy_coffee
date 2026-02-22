import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/arb/app_localizations.dart';
import 'package:very_yummy_coffee_mobile_app/menu_items/menu_items.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

import '../../helpers/helpers.dart';

class _MockMenuItemsBloc extends MockBloc<MenuItemsEvent, MenuItemsState>
    implements MenuItemsBloc {}

class _MockGoRouter extends Mock implements GoRouter {}

const _testGroup = MenuGroup(
  id: 'drinks',
  name: 'Drinks',
  description: 'Coffee, tea & beverages',
  color: 0xFFC96B45,
);

extension _MenuItemsTester on WidgetTester {
  Future<void> pumpMenuItemsView(MenuItemsState state) async {
    final bloc = _MockMenuItemsBloc();
    when(() => bloc.state).thenReturn(state);
    whenListen(bloc, Stream.value(state));

    await pumpWidget(
      BlocProvider<MenuItemsBloc>.value(
        value: bloc,
        child: MockGoRouterProvider(
          goRouter: _MockGoRouter(),
          child: MaterialApp(
            theme: CoffeeTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: MenuItemsView()),
          ),
        ),
      ),
    );
    await pump();
  }
}

void main() {
  group('MenuItemsView', () {
    group('loading state', () {
      testWidgets('shows CircularProgressIndicator', (tester) async {
        await tester.pumpMenuItemsView(
          const MenuItemsState(status: MenuItemsStatus.loading),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('initial state', () {
      testWidgets('shows CircularProgressIndicator', (tester) async {
        await tester.pumpMenuItemsView(const MenuItemsState());
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('failure state', () {
      testWidgets('shows error message', (tester) async {
        await tester.pumpMenuItemsView(
          const MenuItemsState(status: MenuItemsStatus.failure),
        );
        expect(find.text(tester.l10n.errorSomethingWentWrong), findsOneWidget);
      });
    });

    group('success state', () {
      const testItems = [
        MenuItem(id: '1', name: 'Espresso', price: 300, groupId: 'drinks'),
        MenuItem(id: '2', name: 'Latte', price: 475, groupId: 'drinks'),
      ];

      testWidgets('shows item names', (tester) async {
        await tester.pumpMenuItemsView(
          const MenuItemsState(
            status: MenuItemsStatus.success,
            menuItems: testItems,
          ),
        );
        expect(find.text('Espresso'), findsOneWidget);
        expect(find.text('Latte'), findsOneWidget);
      });

      testWidgets('shows formatted prices', (tester) async {
        await tester.pumpMenuItemsView(
          const MenuItemsState(
            status: MenuItemsStatus.success,
            menuItems: testItems,
          ),
        );
        expect(find.text(r'$3.00'), findsOneWidget);
        expect(find.text(r'$4.75'), findsOneWidget);
      });

      testWidgets('shows group name in header when group is in state', (
        tester,
      ) async {
        await tester.pumpMenuItemsView(
          const MenuItemsState(
            status: MenuItemsStatus.success,
            group: _testGroup,
          ),
        );
        expect(find.text('Drinks'), findsOneWidget);
        expect(find.text('Coffee, tea & beverages'), findsOneWidget);
      });
    });

    group('back button', () {
      testWidgets('renders back arrow icon', (tester) async {
        await tester.pumpMenuItemsView(
          const MenuItemsState(status: MenuItemsStatus.success),
        );
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });
  });
}
