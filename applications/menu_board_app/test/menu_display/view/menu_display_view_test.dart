import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/bloc/menu_display_bloc.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/menu_display_view.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/featured_item_panel.dart';
import 'package:very_yummy_coffee_menu_board_app/order_status/order_status.dart';

import '../../helpers/helpers.dart';

class _MockMenuDisplayBloc extends MockBloc<MenuDisplayEvent, MenuDisplayState>
    implements MenuDisplayBloc {}

class _MockOrderStatusBloc extends MockBloc<OrderStatusEvent, OrderStatusState>
    implements OrderStatusBloc {}

void main() {
  group('MenuDisplayView', () {
    late MenuDisplayBloc menuDisplayBloc;
    late OrderStatusBloc orderStatusBloc;

    const group1 = MenuGroup(
      id: 'g1',
      name: 'Espresso',
      description: 'Coffee drinks',
      color: 0xFF000000,
    );

    const group2 = MenuGroup(
      id: 'g2',
      name: 'Cold Brew',
      description: 'Cold drinks',
      color: 0xFF111111,
    );

    const item1 = MenuItem(
      id: 'i1',
      name: 'Americano',
      price: 400,
      groupId: 'g1',
    );

    const item2 = MenuItem(
      id: 'i2',
      name: 'Nitro Cold Brew',
      price: 550,
      groupId: 'g2',
    );

    setUp(() {
      menuDisplayBloc = _MockMenuDisplayBloc();
      orderStatusBloc = _MockOrderStatusBloc();
      when(() => orderStatusBloc.state).thenReturn(const OrderStatusState());
    });

    Widget buildSubject() {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: menuDisplayBloc),
          BlocProvider.value(value: orderStatusBloc),
        ],
        child: const MenuDisplayView(),
      );
    }

    testWidgets('renders CircularProgressIndicator when status is loading', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => menuDisplayBloc.state).thenReturn(
        const MenuDisplayState(status: MenuDisplayStatus.loading),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders CircularProgressIndicator when status is initial', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => menuDisplayBloc.state).thenReturn(const MenuDisplayState());

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders three-panel layout when status is success with data', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => menuDisplayBloc.state).thenReturn(
        const MenuDisplayState(
          status: MenuDisplayStatus.success,
          groups: [group1, group2],
          items: [item1, item2],
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.text('Americano'), findsWidgets);
      expect(find.text('Nitro Cold Brew'), findsWidgets);
      expect(find.text('Espresso'), findsWidgets);
      expect(find.text('Cold Brew'), findsWidgets);
    });

    testWidgets('renders without crash when groups is empty', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => menuDisplayBloc.state).thenReturn(
        const MenuDisplayState(status: MenuDisplayStatus.success),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders failure message when status is failure', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => menuDisplayBloc.state).thenReturn(
        const MenuDisplayState(status: MenuDisplayStatus.failure),
      );

      await tester.pumpApp(buildSubject());

      expect(find.text('Failed to load menu.'), findsOneWidget);
    });

    testWidgets(
      'featured panels receive items from first and last groups',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        when(() => menuDisplayBloc.state).thenReturn(
          const MenuDisplayState(
            status: MenuDisplayStatus.success,
            groups: [group1, group2],
            items: [item1, item2],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('Americano'), findsWidgets);
        expect(find.text('Nitro Cold Brew'), findsWidgets);
      },
    );

    testWidgets(
      'shows OrderStatusPanel when orders exist',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        when(() => menuDisplayBloc.state).thenReturn(
          const MenuDisplayState(
            status: MenuDisplayStatus.success,
            groups: [group1, group2],
            items: [item1, item2],
          ),
        );
        when(() => orderStatusBloc.state).thenReturn(
          OrderStatusState(
            status: OrderStatusStatus.success,
            inProgressOrders: [
              Order(
                id: 'order-1',
                items: const [
                  LineItem(id: 'li-1', name: 'Latte', price: 550),
                ],
                status: OrderStatus.inProgress,
                customerName: 'Marcus',
                submittedAt: DateTime(2026),
              ),
            ],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.byType(OrderStatusPanel), findsOneWidget);
      },
    );

    testWidgets(
      'shows right FeaturedItemPanel when no orders exist',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        when(() => menuDisplayBloc.state).thenReturn(
          const MenuDisplayState(
            status: MenuDisplayStatus.success,
            groups: [group1, group2],
            items: [item1, item2],
          ),
        );
        when(() => orderStatusBloc.state).thenReturn(
          const OrderStatusState(status: OrderStatusStatus.success),
        );

        await tester.pumpApp(buildSubject());

        // Two FeaturedItemPanels — left and right (fallback).
        expect(find.byType(FeaturedItemPanel), findsNWidgets(2));
        expect(find.byType(OrderStatusPanel), findsNothing);
      },
    );
  });
}
