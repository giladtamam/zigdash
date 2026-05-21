import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/services/automation_config_publisher.dart';

void main() {
  group('AutomationConfigPublisher builders', () {
    test('config/state topics are keyed by panel id', () {
      expect(AutomationConfigPublisher.configTopic('abc'),
          'zigdash/automation/schedule/abc/config');
      expect(AutomationConfigPublisher.stateTopic('abc'),
          'zigdash/automation/schedule/abc/state');
      expect(AutomationConfigPublisher.bridgeStateTopic,
          'zigdash/automation/bridge/state');
    });

    test('buildPayload emits the wire contract', () {
      const cfg = ScheduleConfig(openTime: '06:30', closeTime: '20:00');
      final raw = AutomationConfigPublisher.buildPayload(
        name: 'Living-room shutter',
        target: 'zigbee2mqtt/living_shutter/set',
        config: cfg,
      );
      final j = json.decode(raw) as Map<String, dynamic>;
      expect(j['name'], 'Living-room shutter');
      expect(j['target'], 'zigbee2mqtt/living_shutter/set');
      expect(j['openTime'], '06:30');
      expect(j['closeTime'], '20:00');
      expect(j['openPayload'], '{"state":"OPEN"}');
      expect(j['enabled'], true);
    });
  });
}
