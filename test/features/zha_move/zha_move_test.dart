// Moving from ZHA (zha-migration.md, Phase 1): the flags that make a
// finished setup count as a move, the guide's language, and the events.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/features/onboarding/setup/ai_help.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/zha_move/zha_move.dart';
import 'package:zigdash/mqtt/ha_mqtt_client.dart' show HaFacts;

void main() {
  final now = DateTime(2026, 11, 17, 12);
  int ms(DateTime t) => t.millisecondsSinceEpoch;

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('from_zha: moving beats devices, both last 60 days', () async {
    var prefs = await prefsWith({
      zhaMovingAtKey: ms(now.subtract(const Duration(days: 59))),
      zhaFoundAtKey: ms(now),
    });
    expect(fromZhaOf(prefs, now: now), FromZha.moving);
    expect(zhaMoving(prefs, now: now), isTrue);

    prefs = await prefsWith({
      zhaMovingAtKey: ms(now.subtract(const Duration(days: 61))),
      zhaFoundAtKey: ms(now.subtract(const Duration(days: 3))),
    });
    expect(fromZhaOf(prefs, now: now), FromZha.devices);
    expect(zhaMoving(prefs, now: now), isFalse);

    prefs = await prefsWith({zhaAnsweredKey: true});
    expect(
      fromZhaOf(prefs, now: now),
      isNull,
      reason: 'a ZHA answer alone never counts',
    );
  });

  test('a finished setup ends the move', () async {
    final prefs = await prefsWith({
      zhaMovingAtKey: ms(now),
      zhaFoundAtKey: ms(now),
    });
    await endZhaMove(prefs);
    expect(fromZhaOf(prefs, now: now), isNull);
  });

  test('the guide in the app\'s language, English otherwise', () {
    expect(
      zhaGuideUrlFor(const Locale('de')).toString(),
      'https://zigdash.app/zha/de/',
    );
    expect(
      zhaGuideUrlFor(const Locale('pt', 'BR')).toString(),
      'https://zigdash.app/zha/pt/',
    );
    expect(
      zhaGuideUrlFor(const Locale('en')).toString(),
      'https://zigdash.app/zha/',
    );
    expect(
      zhaGuideUrlFor(const Locale('ja')).toString(),
      'https://zigdash.app/zha/',
    );
    expect(zhaGuideUrlFor(null).toString(), 'https://zigdash.app/zha/');
  });

  test('events: zha_move and from_zha carry no names or addresses', () {
    expect(const ZhaMoveEvent(ZhaMoveStep.notNow, ZhaMoveFrom.notAdmin).props, {
      'step': 'not_now',
      'from': 'not_admin',
    });
    expect(
      const ZhaMoveEvent(ZhaMoveStep.opened, ZhaMoveFrom.demo).name,
      'zha_move',
    );
    expect(
      const SetupStep(SetupStepKind.complete, fromZha: FromZha.moving).props,
      {'step': 'complete', 'from_zha': 'moving'},
    );
    expect(
      const HaImportEvent(HaImportStep.preview, devices: 3, fromZha: 2).props,
      {'step': 'preview', 'devices': '1-5', 'from_zha': '1-5'},
    );
  });

  test('Ask your AI says ZHA was found, or that there are no apps', () {
    String write(HaFacts? facts) => aiHelpText(
      AiHelpFacts(
        from: AiHelpFrom.haConnect,
        platform: SetupPlatform.homeAssistant,
        haProblem: HaConnectProblem.noMqtt,
        haFacts: facts,
      ),
    );
    expect(
      write(const HaFacts(apps: false, zhaDevices: 23)),
      contains('runs in ZHA'),
    );
    expect(
      write(const HaFacts(apps: false, zhaDevices: 23)),
      contains('23 devices'),
    );
    expect(
      write(const HaFacts(apps: false, zhaDevices: 0)),
      contains('no apps'),
    );
    final plain = write(const HaFacts(apps: true, zhaDevices: 0));
    expect(plain, contains('has no MQTT integration.'));
    expect(plain, isNot(contains('runs in ZHA')));
    expect(plain, isNot(contains('no apps')));
  });
}
