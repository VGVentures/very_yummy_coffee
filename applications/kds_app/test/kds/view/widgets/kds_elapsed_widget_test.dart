import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_elapsed_widget.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('KdsElapsedWidget', () {
    testWidgets(
      'shows dash when submittedAt is null and isLiveTimer is false',
      (tester) async {
        await tester.pumpApp(
          const KdsElapsedWidget(submittedAt: null, isLiveTimer: false),
        );

        expect(find.text('—'), findsOneWidget);
      },
    );

    testWidgets(
      'shows dash when submittedAt is null and isLiveTimer is true',
      (tester) async {
        await tester.pumpApp(
          const KdsElapsedWidget(submittedAt: null, isLiveTimer: true),
        );

        expect(find.text('—'), findsOneWidget);
      },
    );

    testWidgets(
      'shows MM:SS format when isLiveTimer is true and submittedAt is set',
      (tester) async {
        final submittedAt = DateTime.now().subtract(
          const Duration(seconds: 90),
        );

        await tester.pumpApp(
          KdsElapsedWidget(submittedAt: submittedAt, isLiveTimer: true),
        );

        expect(
          find.textContaining(RegExp(r'^\d{2}:\d{2}$')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows minutes-ago label when isLiveTimer is false and age < 1 hour',
      (tester) async {
        final submittedAt = DateTime.now().subtract(
          const Duration(minutes: 5),
        );

        await tester.pumpApp(
          KdsElapsedWidget(submittedAt: submittedAt, isLiveTimer: false),
        );

        final l10n = tester.l10n;
        expect(find.text(l10n.ageMinutesAgo(5)), findsOneWidget);
      },
    );

    testWidgets(
      'rebuilds without errors after timer fires',
      (tester) async {
        final submittedAt = DateTime.now().subtract(
          const Duration(seconds: 30),
        );

        await tester.pumpApp(
          KdsElapsedWidget(submittedAt: submittedAt, isLiveTimer: true),
        );

        // Advance by 1 second to fire the periodic timer.
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(KdsElapsedWidget), findsOneWidget);
      },
    );
  });
}
