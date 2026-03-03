import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kds_app/kds/kds.dart';

import '../../helpers/helpers.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockKdsBloc extends MockBloc<KdsEvent, KdsState> implements KdsBloc {}

void main() {
  group('KdsPage', () {
    late OrderRepository orderRepository;

    setUp(() {
      orderRepository = _MockOrderRepository();
      when(() => orderRepository.ordersStream).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    testWidgets(
      'creates KdsBloc and renders KdsView',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpApp(
          const KdsPage(),
          orderRepository: orderRepository,
        );

        expect(find.byType(KdsView), findsOneWidget);
        verify(() => orderRepository.ordersStream).called(1);
      },
    );

    testWidgets(
      'renders KdsView as child when BlocProvider is provided externally',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final kdsBloc = _MockKdsBloc();
        when(() => kdsBloc.state).thenReturn(const KdsState());

        await tester.pumpApp(
          BlocProvider<KdsBloc>.value(
            value: kdsBloc,
            child: const KdsView(),
          ),
        );

        expect(find.byType(KdsView), findsOneWidget);
      },
    );
  });
}
