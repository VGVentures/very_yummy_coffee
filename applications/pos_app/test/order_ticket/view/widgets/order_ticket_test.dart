import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/bloc/order_ticket_bloc.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/view/widgets/order_ticket.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

import '../../../helpers/pump_app.dart';

class _MockMenuBloc extends MockBloc<MenuEvent, MenuState>
    implements MenuBloc {}

class _MockOrderTicketBloc extends MockBloc<OrderTicketEvent, OrderTicketState>
    implements OrderTicketBloc {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Espresso',
  price: 300,
  quantity: 1,
  menuItemId: 'menu-1',
);

const _testOrder = Order(
  id: 'order-1',
  items: [_testItem],
  status: OrderStatus.pending,
);

const _availableMenuItem = MenuItem(
  id: 'menu-1',
  name: 'Espresso',
  price: 300,
  groupId: 'g1',
);

const _unavailableMenuItem = MenuItem(
  id: 'menu-1',
  name: 'Espresso',
  price: 300,
  groupId: 'g1',
  available: false,
);

void main() {
  late _MockMenuBloc menuBloc;
  late _MockOrderTicketBloc orderTicketBloc;

  setUp(() {
    menuBloc = _MockMenuBloc();
    orderTicketBloc = _MockOrderTicketBloc();
  });

  Widget buildSubject() => MultiBlocProvider(
    providers: [
      BlocProvider<MenuBloc>.value(value: menuBloc),
      BlocProvider<OrderTicketBloc>.value(value: orderTicketBloc),
    ],
    child: const OrderTicket(),
  );

  group('OrderTicket', () {
    group('with available items', () {
      setUp(() {
        when(() => menuBloc.state).thenReturn(
          const MenuState(
            status: MenuStatus.success,
            allItems: [_availableMenuItem],
          ),
        );
        when(() => orderTicketBloc.state).thenReturn(
          const OrderTicketState(
            order: _testOrder,
            status: OrderTicketStatus.idle,
          ),
        );
      });

      testWidgets('shows item name', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.text('Espresso'), findsOneWidget);
      });

      testWidgets('does not show OutOfStockBadge', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.byType(OutOfStockBadge), findsNothing);
      });

      testWidgets('charge button is enabled', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.textContaining('Charge'), findsOneWidget);
      });
    });

    group('with unavailable items', () {
      setUp(() {
        when(() => menuBloc.state).thenReturn(
          const MenuState(
            status: MenuStatus.success,
            allItems: [_unavailableMenuItem],
          ),
        );
        when(() => orderTicketBloc.state).thenReturn(
          const OrderTicketState(
            order: _testOrder,
            status: OrderTicketStatus.idle,
          ),
        );
      });

      testWidgets('shows OutOfStockBadge on unavailable line item', (
        tester,
      ) async {
        await tester.pumpApp(buildSubject());
        expect(find.byType(OutOfStockBadge), findsOneWidget);
      });

      testWidgets('shows warning message', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(
          find.text('Remove unavailable items to proceed'),
          findsOneWidget,
        );
      });

      testWidgets('disables charge button', (tester) async {
        await tester.pumpApp(buildSubject());

        final button = tester.widget<BaseButton>(
          find.byType(BaseButton),
        );
        expect(button.onPressed, isNull);
      });
    });

    group('empty state', () {
      testWidgets('shows empty message when no order', (tester) async {
        when(() => menuBloc.state).thenReturn(const MenuState());
        when(
          () => orderTicketBloc.state,
        ).thenReturn(const OrderTicketState());

        await tester.pumpApp(buildSubject());

        expect(find.text('No items — tap menu to add'), findsOneWidget);
      });
    });
  });
}
