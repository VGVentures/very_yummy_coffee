import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';

import '../../helpers/helpers.dart';

class _MockMenuGroupsBloc extends MockBloc<MenuGroupsEvent, MenuGroupsState>
    implements MenuGroupsBloc {}

void main() {
  group('MenuGroupsView', () {
    late MenuGroupsBloc bloc;

    setUp(() {
      bloc = _MockMenuGroupsBloc();
    });

    Widget buildSubject() => BlocProvider.value(
      value: bloc,
      child: const MenuGroupsView(),
    );

    group('CartStatus.loading', () {
      testWidgets('shows CircularProgressIndicator', (tester) async {
        const state = MenuGroupsState(status: MenuGroupsStatus.loading);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('MenuGroupsStatus.failure', () {
      testWidgets('shows error message', (tester) async {
        const state = MenuGroupsState(status: MenuGroupsStatus.failure);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(buildSubject());

        expect(find.text('Something went wrong'), findsOneWidget);
      });
    });

    group('MenuGroupsStatus.success', () {
      setUp(() {
        const state = MenuGroupsState(status: MenuGroupsStatus.success);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));
      });

      testWidgets('shows cart icon button', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      });

      testWidgets('tapping cart icon navigates to /menu/cart', (tester) async {
        final goRouter = MockGoRouter();
        await tester.pumpApp(buildSubject(), goRouter: goRouter);

        await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
        await tester.pump();

        verify(() => goRouter.go('/menu/cart')).called(1);
      });
    });
  });
}
