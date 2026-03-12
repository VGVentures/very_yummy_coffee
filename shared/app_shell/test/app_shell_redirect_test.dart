import 'package:app_shell/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirectLogic', () {
    test('returns connecting path when disconnected and not on connecting', () {
      expect(
        redirectLogic(
          AppStatus.disconnected,
          '/home',
          connectedHomePath: '/home',
        ),
        AppShellRoutes.connecting,
      );
    });

    test('returns connecting path when initial and not on connecting', () {
      expect(
        redirectLogic(
          AppStatus.initial,
          '/ordering',
          connectedHomePath: '/ordering',
        ),
        AppShellRoutes.connecting,
      );
    });

    test('returns connectedHomePath when connected and on connecting', () {
      expect(
        redirectLogic(
          AppStatus.connected,
          AppShellRoutes.connecting,
          connectedHomePath: '/ordering',
        ),
        '/ordering',
      );
    });

    test('returns null when disconnected but path is allowed', () {
      expect(
        redirectLogic(
          AppStatus.disconnected,
          '/order-complete/123',
          connectedHomePath: '/ordering',
          allowedWhenDisconnected: const ['/order-complete/'],
        ),
        isNull,
      );
    });

    test(
      'returns null when disconnected but path contains allowed substring',
      () {
        expect(
          redirectLogic(
            AppStatus.disconnected,
            '/home/menu/cart/checkout/confirmation/xyz',
            connectedHomePath: '/home',
            allowedWhenDisconnected: const ['/confirmation/'],
          ),
          isNull,
        );
      },
    );

    test('returns null when connected and not on connecting', () {
      expect(
        redirectLogic(
          AppStatus.connected,
          '/home',
          connectedHomePath: '/home',
        ),
        isNull,
      );
    });

    test('returns null when disconnected on connecting path', () {
      expect(
        redirectLogic(
          AppStatus.disconnected,
          AppShellRoutes.connecting,
          connectedHomePath: '/home',
        ),
        isNull,
      );
    });
  });
}
