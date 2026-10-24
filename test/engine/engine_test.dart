import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/engine/engine_status.dart';

/// A broker stand-in: records publishes and lets the test answer them.
class FakeLink implements HubLink {
  final published = <(String, String, bool)>[];
  final _streams = <String, StreamController<String>>{};
  void Function(String topic, String payload)? onPublish;

  @override
  Stream<String> listen(String topic) =>
      (_streams[topic] ??= StreamController<String>.broadcast()).stream;

  void emit(String topic, String payload) => _streams[topic]?.add(payload);

  @override
  void publish(String topic, String payload, {bool retain = false}) {
    published.add((topic, payload, retain));
    onPublish?.call(topic, payload);
  }
}

String tx(String payload) => '${(jsonDecode(payload) as Map)['transaction']}';

void main() {
  final now = DateTime.utc(2026, 10, 22, 16);
  const hub28 = HubInfo(version: '2.8.0', externalJsAllowed: true);
  EngineReport report({bool stopped = false, DateTime? at}) => EngineReport(
      version: '3.0.0', runningOn: 'hub', rulesLoaded: 2, rulesUnknown: const [],
      stoppedSelf: stopped, at: at ?? now);

  group('HubInfo', () {
    test('reads version and the external JavaScript flag', () {
      final fresh = HubInfo.decode(jsonEncode({
        'version': '2.14.1',
        'config': {'advanced': {'enable_external_js': false}},
      }))!;
      expect(fresh.version, '2.14.1');
      expect(fresh.externalJsAllowed, isFalse);
      final old = HubInfo.decode(jsonEncode({'version': '2.8.0', 'config': {'advanced': {}}}))!;
      expect(old.externalJsAllowed, isTrue);
    });

    test('version floor 2.4', () {
      expect(const HubInfo(version: '2.3.9', externalJsAllowed: true).versionSupported, isFalse);
      expect(const HubInfo(version: '1.42.0', externalJsAllowed: true).versionSupported, isFalse);
      expect(const HubInfo(version: '2.4.0', externalJsAllowed: true).versionSupported, isTrue);
      expect(const HubInfo(version: '2.14.1-dev', externalJsAllowed: true).versionSupported, isTrue);
      expect(const HubInfo(version: '', externalJsAllowed: true).versionSupported, isTrue);
    });
  });

  group('EngineHealth.phase', () {
    HubEnginePhase phase({HubInfo? hub = hub28, List<String>? ext = const [], EngineReport? r, DateTime? heard}) =>
        EngineHealth.phase(hub: hub, extensions: ext, report: r, lastHeardAt: heard, now: now);

    test('checking until bridge info and extensions are known', () {
      expect(phase(hub: null), HubEnginePhase.checking);
      expect(phase(ext: null), HubEnginePhase.checking);
    });
    test('too old below 2.4', () {
      expect(phase(hub: const HubInfo(version: '2.2.0', externalJsAllowed: true)), HubEnginePhase.tooOld);
    });
    test('not installed vs needs consent', () {
      expect(phase(), HubEnginePhase.notInstalled);
      expect(phase(hub: const HubInfo(version: '2.14.1', externalJsAllowed: false)), HubEnginePhase.needsConsent);
    });
    test('running, paused by silence, paused by a stale retained report', () {
      const ext = [engineExtensionName];
      expect(phase(ext: ext, r: report(), heard: now), HubEnginePhase.running);
      expect(phase(ext: ext, r: report(), heard: now.subtract(const Duration(seconds: 91))), HubEnginePhase.paused);
      expect(phase(ext: ext, r: report(at: now.subtract(const Duration(hours: 1))), heard: now), HubEnginePhase.paused);
      expect(phase(ext: ext), HubEnginePhase.paused, reason: 'installed, never reported');
    });
    test('stopped itself', () {
      expect(phase(ext: const [engineExtensionName], r: report(stopped: true), heard: now), HubEnginePhase.stoppedSelf);
    });
  });

  test('report decoding, outdated and clock checks', () {
    final r = EngineReport.decode(
        '{"engine":"3.0.0","running_on":"hub","rules_loaded":1,"rules_unknown":["f"],"stopped_self":false,"at":"2026-10-22T15:39:51.388Z"}')!;
    expect(r.rulesUnknown, ['f']);
    expect(EngineReport.decode(''), isNull);
    expect(EngineHealth.outdated(r, '3.0.1'), isTrue);
    expect(EngineHealth.outdated(r, '3.0.0'), isFalse);
    expect(EngineHealth.clockOff(r, DateTime.utc(2026, 10, 22, 15, 41)), isFalse);
    expect(EngineHealth.clockOff(r, DateTime.utc(2026, 10, 22, 15, 50)), isTrue);
  });

  test('the bundled engine source carries its version', () {
    final source = File('hub/zigdash-engine.js').readAsStringSync();
    expect(bundledEngineVersion(source), '3.1.5');
  });

  group('EngineInstaller', () {
    test('install saves the extension and reads the answer', () async {
      final link = FakeLink();
      link.onPublish = (topic, payload) {
        if (topic == 'zigbee2mqtt/bridge/request/extension/save') {
          final j = jsonDecode(payload) as Map;
          expect(j['name'], engineExtensionName);
          expect(j['code'], 'code');
          scheduleMicrotask(() => link.emit('zigbee2mqtt/bridge/response/extension/save',
              jsonEncode({'status': 'ok', 'data': {}, 'transaction': j['transaction']})));
        }
      };
      final answer = await EngineInstaller(link, base: 'zigbee2mqtt').install('code');
      expect(answer.$1, HubAnswer.ok);
    });

    test('a hub that blocks extensions never answers', () async {
      final link = FakeLink();
      final answer = await EngineInstaller(link, base: 'zigbee2mqtt',
              answerWithin: const Duration(milliseconds: 50))
          .install('code');
      expect(answer.$1, HubAnswer.noAnswer);
    });

    test('an error answer is passed on; another request\'s answer is ignored', () async {
      final link = FakeLink();
      link.onPublish = (topic, payload) => scheduleMicrotask(() {
            link.emit('zigbee2mqtt/bridge/response/extension/save',
                jsonEncode({'status': 'ok', 'transaction': 'someone-else'}));
            link.emit('zigbee2mqtt/bridge/response/extension/save',
                jsonEncode({'status': 'error', 'error': 'SyntaxError', 'transaction': tx(payload)}));
          });
      final answer = await EngineInstaller(link, base: 'zigbee2mqtt').install('code');
      expect(answer, (HubAnswer.refused, 'SyntaxError'));
    });

    test('consent: allow extensions, restart, wait until Zigbee2MQTT is back', () async {
      final link = FakeLink();
      link.onPublish = (topic, payload) {
        if (topic.endsWith('/bridge/request/options')) {
          expect((jsonDecode(payload) as Map)['options'], {'advanced': {'enable_external_js': true}});
          scheduleMicrotask(() => link.emit('zigbee2mqtt/bridge/response/options',
              jsonEncode({'status': 'ok', 'transaction': tx(payload)})));
        }
        if (topic.endsWith('/bridge/request/restart')) {
          scheduleMicrotask(() {
            link.emit('zigbee2mqtt/bridge/state', '{"state":"offline"}');
            link.emit('zigbee2mqtt/bridge/state', '{"state":"online"}');
          });
        }
      };
      final answer = await EngineInstaller(link, base: 'zigbee2mqtt').allowExtensionsAndRestart();
      expect(answer, HubAnswer.ok);
      expect(link.published.map((p) => p.$1),
          ['zigbee2mqtt/bridge/request/options', 'zigbee2mqtt/bridge/request/restart']);
    });

    test('start again publishes the control command', () {
      final link = FakeLink();
      EngineInstaller(link, base: 'zigbee2mqtt').startAgain();
      expect(link.published.single.$1, EngineTopics.control);
      expect(link.published.single.$2, '{"cmd":"start"}');
    });
  });
}
