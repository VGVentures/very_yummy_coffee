import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_mobile_app/item_detail/item_detail.dart';

import '../../helpers/helpers.dart';

class _MockItemDetailBloc extends MockBloc<ItemDetailEvent, ItemDetailState>
    implements ItemDetailBloc {}

class _MockItemDetailState extends Mock implements ItemDetailState {}

class _MockGoRouter extends Mock implements GoRouter {}

const _testItem = MenuItem(
  id: '1',
  name: 'Espresso',
  price: 300,
  groupId: 'drinks',
);

void main() {
  group('ItemDetailView', () {
    late ItemDetailBloc bloc;
    late ItemDetailState state;

    setUp(() {
      bloc = _MockItemDetailBloc();
      state = _MockItemDetailState();
      when(() => bloc.state).thenReturn(state);
    });

    group('loading state', () {
      testWidgets('shows CircularProgressIndicator when item is null', (
        tester,
      ) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('loaded state', () {
      setUp(() {
        final loadedState = _MockItemDetailState();
        when(() => loadedState.status).thenReturn(ItemDetailStatus.idle);
        when(() => loadedState.item).thenReturn(_testItem);
        when(() => loadedState.selectedSize).thenReturn(DrinkSize.medium);
        when(() => loadedState.selectedMilk).thenReturn(MilkOption.whole);
        when(() => loadedState.selectedExtras).thenReturn(const []);
        when(() => loadedState.quantity).thenReturn(1);
        when(() => loadedState.totalPrice).thenReturn(300);
        when(() => bloc.state).thenReturn(loadedState);
      });

      testWidgets('shows item name', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text('Espresso'), findsOneWidget);
      });

      testWidgets('shows formatted price', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text(r'$3.00'), findsOneWidget);
      });

      testWidgets('shows size section label', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text('Size'), findsOneWidget);
      });

      testWidgets('shows milk section label', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text('Milk'), findsOneWidget);
      });

      testWidgets('shows extras section label', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text('Extras'), findsOneWidget);
      });

      testWidgets('shows add to cart button with total price', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text(r'Add to Cart — $3.00'), findsOneWidget);
      });

      testWidgets('shows quantity as 1 by default', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('shows updated total price for quantity 2', (tester) async {
        final state = _MockItemDetailState();
        when(() => state.status).thenReturn(ItemDetailStatus.idle);
        when(() => state.item).thenReturn(_testItem);
        when(() => state.selectedSize).thenReturn(DrinkSize.medium);
        when(() => state.selectedMilk).thenReturn(MilkOption.whole);
        when(() => state.selectedExtras).thenReturn(const []);
        when(() => state.quantity).thenReturn(2);
        when(() => state.totalPrice).thenReturn(600);

        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        expect(find.text(r'Add to Cart — $6.00'), findsOneWidget);
      });
    });

    group('adding state', () {
      testWidgets('shows CircularProgressIndicator in add button', (
        tester,
      ) async {
        final state = _MockItemDetailState();
        when(() => state.status).thenReturn(ItemDetailStatus.adding);
        when(() => state.item).thenReturn(_testItem);
        when(() => state.selectedSize).thenReturn(DrinkSize.medium);
        when(() => state.selectedMilk).thenReturn(MilkOption.whole);
        when(() => state.selectedExtras).thenReturn(const []);
        when(() => state.quantity).thenReturn(1);
        when(() => state.totalPrice).thenReturn(300);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
        );

        // One for the button spinner (item is loaded so no full-screen spinner)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text(r'Add to Cart — $3.00'), findsNothing);
      });
    });

    group('added state', () {
      testWidgets('navigates to /cart when status becomes added', (
        tester,
      ) async {
        final goRouter = _MockGoRouter();
        final state = _MockItemDetailState();
        when(() => state.status).thenReturn(ItemDetailStatus.added);
        when(() => state.item).thenReturn(_testItem);
        when(() => state.selectedSize).thenReturn(DrinkSize.medium);
        when(() => state.selectedMilk).thenReturn(MilkOption.whole);
        when(() => state.selectedExtras).thenReturn(const []);
        when(() => state.quantity).thenReturn(1);
        when(() => state.totalPrice).thenReturn(300);
        when(() => bloc.state).thenReturn(state);
        whenListen(bloc, Stream.value(state));

        await tester.pumpApp(
          BlocProvider.value(
            value: bloc,
            child: const ItemDetailView(),
          ),
          goRouter: goRouter,
        );

        verify(() => goRouter.go('/menu/cart')).called(1);
      });
    });
  });
}
