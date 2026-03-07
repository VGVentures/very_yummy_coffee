import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/kds.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_column.dart';

import '../../helpers/helpers.dart';

class _MockKdsBloc extends MockBloc<KdsEvent, KdsState> implements KdsBloc {}

const _testItem = LineItem(
  id: 'li-1',
  name: 'Latte',
  price: 450,
);

final _submittedOrder = Order(
  id: 'order-1111',
  items: const [_testItem],
  status: OrderStatus.submitted,
  submittedAt: DateTime(2026, 3, 1, 10),
);

final _inProgressOrder = Order(
  id: 'order-2222',
  items: const [_testItem],
  status: OrderStatus.inProgress,
  submittedAt: DateTime(2026, 3, 1, 10),
);

final _readyOrder = Order(
  id: 'order-3333',
  items: const [_testItem],
  status: OrderStatus.ready,
  submittedAt: DateTime(2026, 3, 1, 10),
);

void main() {
  group('KdsView', () {
    late KdsBloc kdsBloc;

    setUp(() {
      kdsBloc = _MockKdsBloc();
    });

    // KDS is a landscape 3-column layout — tests need a wide viewport.
    void setLandscapeSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Widget buildSubject() => BlocProvider<KdsBloc>.value(
      value: kdsBloc,
      child: const KdsView(),
    );

    testWidgets('renders three KdsColumn widgets', (tester) async {
      setLandscapeSize(tester);
      when(() => kdsBloc.state).thenReturn(const KdsState());

      await tester.pumpApp(buildSubject());

      expect(find.byType(KdsColumn), findsNWidgets(3));
    });

    testWidgets('renders column labels from localization', (tester) async {
      setLandscapeSize(tester);
      when(() => kdsBloc.state).thenReturn(const KdsState());

      await tester.pumpApp(buildSubject());

      final l10n = tester.l10n;
      expect(find.text(l10n.columnNew), findsOneWidget);
      expect(find.text(l10n.columnInProgress), findsOneWidget);
      expect(find.text(l10n.columnReady), findsOneWidget);
    });

    testWidgets(
      'tapping Start action button dispatches KdsOrderStarted',
      (tester) async {
        setLandscapeSize(tester);
        when(() => kdsBloc.state).thenReturn(
          KdsState(
            status: KdsStatus.success,
            newOrders: [_submittedOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        final l10n = tester.l10n;
        await tester.tap(find.text(l10n.actionStart).first);
        await tester.pump();

        verify(
          () => kdsBloc.add(KdsOrderStarted(_submittedOrder.id)),
        ).called(1);
      },
    );

    testWidgets(
      'tapping Mark Ready action button dispatches KdsOrderMarkedReady',
      (tester) async {
        setLandscapeSize(tester);
        when(() => kdsBloc.state).thenReturn(
          KdsState(
            status: KdsStatus.success,
            inProgressOrders: [_inProgressOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        final l10n = tester.l10n;
        await tester.tap(find.text(l10n.actionMarkReady).first);
        await tester.pump();

        verify(
          () => kdsBloc.add(KdsOrderMarkedReady(_inProgressOrder.id)),
        ).called(1);
      },
    );

    testWidgets(
      'tapping Complete action button dispatches KdsOrderCompleted',
      (tester) async {
        setLandscapeSize(tester);
        when(() => kdsBloc.state).thenReturn(
          KdsState(
            status: KdsStatus.success,
            readyOrders: [_readyOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        final l10n = tester.l10n;
        await tester.tap(find.text(l10n.actionComplete).first);
        await tester.pump();

        verify(
          () => kdsBloc.add(KdsOrderCompleted(_readyOrder.id)),
        ).called(1);
      },
    );

    testWidgets(
      'tapping Cancel button dispatches KdsOrderCancelled',
      (tester) async {
        setLandscapeSize(tester);
        when(() => kdsBloc.state).thenReturn(
          KdsState(
            status: KdsStatus.success,
            newOrders: [_submittedOrder],
          ),
        );

        await tester.pumpApp(buildSubject());

        final l10n = tester.l10n;
        await tester.tap(find.text(l10n.actionCancel).first);
        await tester.pump();

        verify(
          () => kdsBloc.add(KdsOrderCancelled(_submittedOrder.id)),
        ).called(1);
      },
    );
  });
}
