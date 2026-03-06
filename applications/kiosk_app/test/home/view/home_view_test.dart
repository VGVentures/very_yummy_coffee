import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_kiosk_app/home/home.dart';

import '../../helpers/helpers.dart';

void main() {
  group('HomeView', () {
    late GoRouter goRouter;

    setUp(() {
      goRouter = MockGoRouter();
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Widget buildSubject() => const HomeView();

    testWidgets('renders brand name', (tester) async {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Very Yummy Coffee'), findsOneWidget);
    });

    testWidgets('renders tagline', (tester) async {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Freshly brewed, just for you.'), findsOneWidget);
    });

    testWidgets('renders start order button', (tester) async {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.text('Start Order'), findsOneWidget);
    });

    testWidgets('navigates to /home/menu on start order tap', (tester) async {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      await tester.tap(find.text('Start Order'));
      verify(() => goRouter.go('/home/menu')).called(1);
    });

    testWidgets('renders background image', (tester) async {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(buildSubject(), goRouter: goRouter);

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
