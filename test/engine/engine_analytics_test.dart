import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';

void main() {
  test('engine_setup: step, where from, Zigbee2MQTT as major.minor only', () {
    final e = EngineEvent(EngineStep.consentShown, z2m: '2.14.1-dev', from: EngineFrom.alerts);
    expect(e.name, 'engine_setup');
    expect(e.props, {'step': 'consent_shown', 'from': 'alerts', 'z2m': '2.14'});
    expect(const EngineEvent(EngineStep.offered).props, {'step': 'offered', 'from': 'automations'});
  });

  test('3.6.2: install_tapped from save, failed with why', () {
    expect(const EngineEvent(EngineStep.installTapped, from: EngineFrom.save).props,
        {'step': 'install_tapped', 'from': 'save'});
    expect(const EngineEvent(EngineStep.failed, from: EngineFrom.save, why: EngineWhy.noExtensions).props,
        {'step': 'failed', 'from': 'save', 'why': 'no_extensions'});
    expect(const HistorySetup(HistorySetupResult.failed, from: HistorySetupFrom.card, why: EngineWhy.noInfo).props,
        {'result': 'failed', 'from': 'card', 'why': 'no_info'});
    expect(const HistorySetup(HistorySetupResult.installed).props, {'result': 'installed', 'from': 'sheet'});
  });

  test('automation_saved: shape only, counts in buckets', () {
    const e = AutomationSaved(
        trigger: 'sun', conditions: 3, action: 'scene', offAfter: true, isNew: true, homeCount: 4, running: false);
    expect(e.props, {'trigger': 'sun', 'conditions': '2+', 'action': 'scene', 'off_after': 'yes', 'new': 'yes', 'count': '4-10', 'running': 'no'});
  });
}
