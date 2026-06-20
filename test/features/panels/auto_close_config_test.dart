import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

void main() {
  group('AutoCloseConfig', () {
    test('defaults match the spec', () {
      final c = AutoCloseConfig();
      expect(c.triggerPath, 'state');
      expect(c.triggerValue, 'ON');
      expect(c.closePayload, '{"state":"OFF"}');
      expect(c.delaySeconds, 60);
      expect(c.enabled, isTrue);
    });

    test('toJson/fromJson round-trips', () {
      final c = AutoCloseConfig(
        triggerPath: 'state',
        triggerValue: 'UNLOCK',
        closePayload: '{"state":"LOCK"}',
        delaySeconds: 30,
        enabled: false,
      );
      final back = AutoCloseConfig.fromJson(c.toJson());
      expect(back.triggerValue, 'UNLOCK');
      expect(back.closePayload, '{"state":"LOCK"}');
      expect(back.delaySeconds, 30);
      expect(back.enabled, isFalse);
    });

    test('fromJson tolerates missing keys (falls back to defaults)', () {
      final c = AutoCloseConfig.fromJson(<String, dynamic>{});
      expect(c.triggerPath, 'state');
      expect(c.triggerValue, 'ON');
      expect(c.delaySeconds, 60);
      expect(c.enabled, isTrue);
    });

    test('clamps delaySeconds into [1, 3600]', () {
      expect(AutoCloseConfig(delaySeconds: 0).delaySeconds, 1);
      expect(AutoCloseConfig(delaySeconds: -5).delaySeconds, 1);
      expect(AutoCloseConfig(delaySeconds: 10000).delaySeconds, 3600);
      expect(AutoCloseConfig(delaySeconds: 60).delaySeconds, 60);
    });

    test('copyWith flips only enabled', () {
      final c = AutoCloseConfig(delaySeconds: 45);
      final off = c.copyWith(enabled: false);
      expect(off.enabled, isFalse);
      expect(off.delaySeconds, 45);
    });
  });
}
