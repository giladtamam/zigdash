import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/router/first_run_redirect.dart';
import 'package:zigdash/core/router/routes.dart';

void main() {
  const start = '/connections/c1/dashboards';

  group('first run (no home yet, not in demo)', () {
    String? redirect(String location) => firstRunRedirect(
          needsSetup: true,
          location: location,
          startLocation: start,
        );

    test('any app location goes to setup, the one door', () {
      expect(redirect(Routes.connections), Routes.setup);
      expect(redirect(Routes.dashboards), Routes.setup);
      expect(redirect(Routes.settings), Routes.setup);
      expect(redirect(Routes.onboarding), Routes.setup);
    });

    test('setup, manual entry and help stay reachable', () {
      expect(redirect(Routes.setup), isNull);
      expect(redirect(Routes.guidedConnect), isNull);
      // 3.1.8: Home Assistant's sign-in, with or without the host seen.
      expect(redirect(Routes.haConnect), isNull);
      // 3.1.7: a new phone scanning another phone's "Share this home" code.
      expect(redirect(Routes.joinHome), isNull);
      expect(redirect(Routes.help), isNull);
    });
  });

  group('after first run', () {
    String? redirect(String location) => firstRunRedirect(
          needsSetup: false,
          location: location,
          startLocation: start,
        );

    test('the retired onboarding address opens the start location', () {
      expect(redirect(Routes.onboarding), start);
    });

    test('everything else is left alone', () {
      expect(redirect(Routes.connections), isNull);
      expect(redirect(Routes.setup), isNull);
      expect(redirect(start), isNull);
    });
  });
}
