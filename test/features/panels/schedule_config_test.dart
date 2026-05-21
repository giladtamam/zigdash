import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

void main() {
  group('ScheduleConfig', () {
    test('defaults match the spec', () {
      const c = ScheduleConfig();
      expect(c.openTime, '07:00');
      expect(c.closeTime, '19:00');
      expect(c.openPayload, '{"state":"OPEN"}');
      expect(c.closePayload, '{"state":"CLOSE"}');
      expect(c.enabled, isTrue);
    });

    test('toJson/fromJson round-trips', () {
      const c = ScheduleConfig(
        openTime: '06:30',
        closeTime: '21:15',
        openPayload: '{"state":"OPEN"}',
        closePayload: '{"state":"CLOSE"}',
        enabled: false,
      );
      final back = ScheduleConfig.fromJson(c.toJson());
      expect(back.openTime, '06:30');
      expect(back.closeTime, '21:15');
      expect(back.enabled, isFalse);
    });

    test('fromJson tolerates missing keys', () {
      final c = ScheduleConfig.fromJson(<String, dynamic>{});
      expect(c.openTime, '07:00');
      expect(c.enabled, isTrue);
    });

    test('copyWith flips only enabled', () {
      const c = ScheduleConfig(openTime: '08:00');
      final off = c.copyWith(enabled: false);
      expect(off.enabled, isFalse);
      expect(off.openTime, '08:00');
    });
  });
}
