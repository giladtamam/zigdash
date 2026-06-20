import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/services/auto_close_config_publisher.dart';
import 'package:zigdash/features/panels/services/automation_config_publisher.dart';

void main() {
  group('AutoCloseConfigPublisher builders', () {
    test('config/state topics are keyed by panel id under autoclose namespace',
        () {
      expect(AutoCloseConfigPublisher.configTopic('abc'),
          'zigdash/automation/autoclose/abc/config');
      expect(AutoCloseConfigPublisher.stateTopic('abc'),
          'zigdash/automation/autoclose/abc/state');
    });

    test('reuses the scheduler-flow heartbeat topic (no duplicate string)', () {
      expect(AutoCloseConfigPublisher.bridgeStateTopic,
          AutomationConfigPublisher.bridgeStateTopic);
    });

    test('buildPayload emits the wire contract', () {
      final cfg = AutoCloseConfig(
        triggerPath: 'state',
        triggerValue: 'ON',
        closePayload: '{"state":"OFF"}',
        delaySeconds: 60,
      );
      final raw = AutoCloseConfigPublisher.buildPayload(
        name: 'Front door auto-close',
        triggerTopic: 'zigbee2mqtt/door',
        target: 'zigbee2mqtt/door/set',
        config: cfg,
      );
      final j = json.decode(raw) as Map<String, dynamic>;
      expect(j['name'], 'Front door auto-close');
      expect(j['triggerTopic'], 'zigbee2mqtt/door');
      expect(j['triggerPath'], 'state');
      expect(j['triggerValue'], 'ON');
      expect(j['target'], 'zigbee2mqtt/door/set');
      expect(j['closePayload'], '{"state":"OFF"}');
      expect(j['delaySeconds'], 60);
      expect(j['enabled'], true);
    });
  });
}
