import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_kiosk_app/item_detail/item_detail.dart';

import '../../helpers/helpers.dart';

class _MockItemDetailBloc extends MockBloc<ItemDetailEvent, ItemDetailState>
    implements ItemDetailBloc {}

void main() {
  group('ItemDetailView', () {
    late ItemDetailBloc itemDetailBloc;
    late GoRouter goRouter;
    const groupId = 'coffee';
    const item = MenuItem(
      id: '1',
      name: 'Latte',
      price: 500,
      groupId: groupId,
    );

    setUp(() {
      itemDetailBloc = _MockItemDetailBloc();
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: itemDetailBloc,
        child: const ItemDetailView(groupId: groupId),
      );
    }

    testWidgets('renders loading indicator when item is null', (tester) async {
      when(() => itemDetailBloc.state).thenReturn(const ItemDetailState());

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders item detail split pane on success', (tester) async {
      when(() => itemDetailBloc.state).thenReturn(
        const ItemDetailState(item: item, status: ItemDetailStatus.idle),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Latte'), findsAtLeast(1));
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('navigates to groupId route on added status', (tester) async {
      when(() => itemDetailBloc.state).thenReturn(
        const ItemDetailState(item: item, status: ItemDetailStatus.idle),
      );
      whenListen(
        itemDetailBloc,
        Stream.value(
          const ItemDetailState(item: item, status: ItemDetailStatus.added),
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);
      await tester.pumpAndSettle();

      verify(() => goRouter.go('/home/menu/$groupId')).called(1);
    });

    testWidgets('disables add to cart when item is unavailable', (
      tester,
    ) async {
      const unavailableItem = MenuItem(
        id: '1',
        name: 'Latte',
        price: 500,
        groupId: groupId,
        available: false,
      );
      when(() => itemDetailBloc.state).thenReturn(
        const ItemDetailState(
          item: unavailableItem,
          status: ItemDetailStatus.idle,
        ),
      );

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(
        find.text('This item is no longer available'),
        findsOneWidget,
      );
    });
  });
}
