import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/features/hub_backup/hub_restore.dart';

/// A broker with a pretend Zigbee2MQTT behind it.
class _Hub implements HubLink {
  _Hub({
    this.externalJs = true,
    this.saveOk = true,
    this.writes = true,
    this.comesBack = true,
  });

  bool externalJs;
  final bool saveOk;
  final bool writes;
  final bool comesBack;
  final published = <String>[];
  final _streams = <String, StreamController<String>>{};

  void _emit(String topic, String payload) =>
      scheduleMicrotask(() => _streams[topic]?.add(payload));

  @override
  Stream<String> listen(String topic) {
    final c = _streams[topic] ??= StreamController<String>.broadcast();
    if (topic == 'zigbee2mqtt/bridge/info') {
      _emit(
        topic,
        jsonEncode({
          'version': '2.13.0',
          'config': {
            'advanced': {'enable_external_js': externalJs},
          },
        }),
      );
    }
    return c.stream;
  }

  void _restart() {
    _emit('zigbee2mqtt/bridge/state', '{"state":"offline"}');
    if (comesBack) {
      Future<void>.delayed(
        const Duration(milliseconds: 5),
        () => _emit('zigbee2mqtt/bridge/state', '{"state":"online"}'),
      );
    }
  }

  @override
  void publish(String topic, String payload, {bool retain = false}) {
    published.add(topic);
    final j = jsonDecode(payload) as Map;
    switch (topic) {
      case 'zigbee2mqtt/bridge/request/options':
        externalJs = true;
        _emit(
          'zigbee2mqtt/bridge/response/options',
          jsonEncode({'status': 'ok', 'transaction': j['transaction']}),
        );
      case 'zigbee2mqtt/bridge/request/restart':
        _restart();
      case 'zigbee2mqtt/bridge/request/extension/save':
      case 'zigbee2mqtt/bridge/request/extension/remove':
        _emit(
          topic.replaceFirst('request', 'response'),
          jsonEncode({
            'status': saveOk ? 'ok' : 'error',
            'transaction': j['transaction'],
          }),
        );
      case restoreTopic:
        if (!writes) return;
        _emit(
          restoreResultTopic,
          jsonEncode({'tx': j['tx'], 'status': 'writing', 'files': 4}),
        );
        _restart();
    }
  }
}

final _zip = Uint8List.fromList(utf8.encode('PK zip'));

Future<(HubRestoreOutcome, List<HubRestoreStage>)> _run(_Hub hub) async {
  final stages = <HubRestoreStage>[];
  final outcome = await HubRestorer(
    hub,
    base: 'zigbee2mqtt',
    answerWithin: const Duration(milliseconds: 200),
    backWithin: const Duration(milliseconds: 300),
  ).restore(_zip, extensionSource: '// js', onStage: stages.add);
  return (outcome, stages);
}

void main() {
  test(
    'sends the extension, then the backup, and waits for the restart',
    () async {
      final hub = _Hub();
      final (outcome, stages) = await _run(hub);
      expect(outcome, HubRestoreOutcome.restored);
      expect(stages, [HubRestoreStage.sending, HubRestoreStage.restarting]);
      expect(hub.published, [
        'zigbee2mqtt/bridge/request/extension/save',
        restoreTopic,
      ]);
    },
  );

  test('extensions off: allows them first, with its restart', () async {
    final hub = _Hub(externalJs: false);
    final (outcome, stages) = await _run(hub);
    expect(outcome, HubRestoreOutcome.restored);
    expect(stages.first, HubRestoreStage.allowingExtensions);
    expect(hub.published.take(2), [
      'zigbee2mqtt/bridge/request/options',
      'zigbee2mqtt/bridge/request/restart',
    ]);
  });

  test('a refused extension stops before anything is sent', () async {
    final hub = _Hub(saveOk: false);
    final (outcome, _) = await _run(hub);
    expect(outcome, HubRestoreOutcome.extensionRefused);
    expect(hub.published, isNot(contains(restoreTopic)));
  });

  test(
    'no word from the extension: nothing written, extension removed',
    () async {
      final hub = _Hub(writes: false);
      final (outcome, _) = await _run(hub);
      expect(outcome, HubRestoreOutcome.notWritten);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(hub.published.last, 'zigbee2mqtt/bridge/request/extension/remove');
    },
  );

  test('written but Zigbee2MQTT never comes back is said as such', () async {
    final (outcome, _) = await _run(_Hub(comesBack: false));
    expect(outcome, HubRestoreOutcome.notBack);
  });
}
