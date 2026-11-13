import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/engine/engine_installer.dart';
import 'package:zigdash/features/hub_backup/hub_backup.dart';
import 'package:zigdash/features/hub_backup/hub_backup_providers.dart';

class _Link implements HubLink {
  final published = <(String, String)>[];
  final _streams = <String, StreamController<String>>{};
  void Function(String topic, String payload)? onPublish;

  @override
  Stream<String> listen(String topic) =>
      (_streams[topic] ??= StreamController<String>.broadcast()).stream;

  void emit(String topic, String payload) => _streams[topic]?.add(payload);

  @override
  void publish(String topic, String payload, {bool retain = false}) {
    published.add((topic, payload));
    onPublish?.call(topic, payload);
  }
}

class _Sink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

String _tx(String payload) => '${(jsonDecode(payload) as Map)['transaction']}';

final _zip = Uint8List.fromList(utf8.encode('PK fake zip'));

/// A link whose Zigbee2MQTT answers a backup request with [answer].
_Link _answering(Map<String, Object?> Function(String tx) answer) {
  final link = _Link();
  link.onPublish = (topic, payload) {
    if (topic == 'zigbee2mqtt/bridge/request/backup') {
      scheduleMicrotask(
        () => link.emit(
          'zigbee2mqtt/bridge/response/backup',
          jsonEncode(answer(_tx(payload))),
        ),
      );
    }
  };
  return link;
}

void main() {
  group('the backup request', () {
    test('returns the zip Zigbee2MQTT sent for this transaction', () async {
      final link = _answering(
        (tx) => {
          'status': 'ok',
          'transaction': tx,
          'data': {'zip': base64Encode(_zip)},
        },
      );
      final answer = await requestHubBackup(link, 'zigbee2mqtt');
      expect((answer as HubBackupZip).bytes, _zip);
      expect(link.published.single.$1, 'zigbee2mqtt/bridge/request/backup');
    });

    test('an error is "can\'t back up", not a failure', () async {
      final link = _answering(
        (tx) => {'status': 'error', 'transaction': tx, 'error': 'nope'},
      );
      expect(
        await requestHubBackup(link, 'zigbee2mqtt'),
        isA<HubBackupRefused>(),
      );
    });

    test('silence ends as no answer', () async {
      final answer = await requestHubBackup(
        _Link(),
        'zigbee2mqtt',
        within: const Duration(milliseconds: 20),
      );
      expect(answer, isA<HubBackupNoAnswer>());
    });

    test('another transaction\'s answer is not ours', () {
      expect(
        decodeBackupResponse(
          jsonEncode({'status': 'ok', 'transaction': 'other', 'data': {}}),
          'mine',
        ),
        isNull,
      );
      expect(decodeBackupResponse('not json', 'mine'), isNull);
    });
  });

  test('a sealed backup opens only with its key', () {
    final key = BackupSeal.newKey();
    final sealed = BackupSeal.seal(key, _zip);
    expect(sealed, isNot(containsAllInOrder(_zip)));
    expect(BackupSeal.unseal(key, sealed), _zip);
    expect(BackupSeal.unseal(BackupSeal.newKey(), sealed), isNull);
  });

  group('the store', () {
    late Directory dir;
    late HubBackupStore store;
    final key = BackupSeal.newKey();
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hub-backup');
      store = HubBackupStore(root: dir, key: () async => key, keep: 3);
    });
    tearDown(() => dir.delete(recursive: true));

    test('keeps the newest per home, sealed, and opens them', () async {
      for (var d = 1; d <= 5; d++) {
        await store.save('home-a', _zip, DateTime.utc(2026, 10, d, 8));
      }
      await store.save('home-b', _zip, DateTime.utc(2026, 10, 9));
      final a = await store.list('home-a');
      expect(a.map((e) => e.at.day), [5, 4, 3]);
      expect(await a.first.file.readAsBytes(), isNot(_zip));
      expect(await store.read(a.first), _zip);
      expect(await store.list('home-b'), hasLength(1));
      await store.deleteHome('home-a');
      expect(await store.list('home-a'), isEmpty);
    });

    test('file names carry the UTC time', () {
      final t = DateTime.utc(2026, 10, 31, 10, 15, 2);
      expect(HubBackupStore.stamp(t), '20261031T101502Z');
      expect(HubBackupStore.parseStamp('20261031T101502Z.zdbk'), t);
      expect(HubBackupStore.parseStamp('notes.txt'), isNull);
    });
  });

  test('a backup is due after a day, or when there is none', () {
    final now = DateTime.utc(2026, 10, 31, 12);
    expect(hubBackupDue(null, now), isTrue);
    expect(hubBackupDue(now.subtract(const Duration(hours: 23)), now), isFalse);
    expect(hubBackupDue(now.subtract(const Duration(hours: 24)), now), isTrue);
  });

  test('a saved copy is named after the home and the day', () {
    expect(
      hubBackupFileName('Beit Gilad!', DateTime(2026, 10, 31, 9)),
      'zigbee2mqtt-backup-beit-gilad-2026-10-31.zip',
    );
  });

  group('taking a backup', () {
    late Directory dir;
    late _Sink sink;
    late ProviderContainer container;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hub-backup');
      sink = _Sink();
      final key = BackupSeal.newKey();
      container = ProviderContainer(
        overrides: [
          analyticsProvider.overrideWithValue(Analytics(sink, enabled: true)),
          hubBackupStoreProvider.overrideWith(
            (ref) async => HubBackupStore(root: dir, key: () async => key),
          ),
        ],
      );
    });
    tearDown(() async {
      container.dispose();
      await dir.delete(recursive: true);
    });

    Future<HubBackupOutcome> take(HubLink link, {bool auto = true}) => container
        .read(hubBackupRunnerProvider)
        .take(
          link,
          'zigbee2mqtt',
          'home-a',
          auto: auto,
          now: DateTime.utc(2026, 10, 31),
        );

    test('keeps it and counts it, nothing about what is inside', () async {
      final link = _answering(
        (tx) => {
          'status': 'ok',
          'transaction': tx,
          'data': {'zip': base64Encode(_zip)},
        },
      );
      expect(await take(link), HubBackupOutcome.made);
      final store = await container.read(hubBackupStoreProvider.future);
      expect(await store.list('home-a'), hasLength(1));
      expect(sink.sent.single.$1, 'hub_backup');
      expect(sink.sent.single.$2, {
        'step': 'made',
        'auto': 'yes',
        'took': 'under_10s',
      });
    });

    test('a hub that can\'t back up is counted as unsupported', () async {
      final link = _answering((tx) => {'status': 'error', 'transaction': tx});
      expect(await take(link, auto: false), HubBackupOutcome.refused);
      expect(sink.sent.single.$2, {'step': 'unsupported', 'auto': 'no'});
    });

    test('an automatic try that gets no answer says which try and why',
        () async {
      final outcome = await container
          .read(hubBackupRunnerProvider)
          .take(
            _Link(),
            'zigbee2mqtt',
            'home-a',
            auto: true,
            attempt: 2,
            now: DateTime.utc(2026, 11, 13),
            why: () => HubBackupWhy.background,
            within: const Duration(milliseconds: 20),
          );
      expect(outcome, HubBackupOutcome.noAnswer);
      expect(sink.sent.single.$2, {
        'step': 'failed',
        'auto': 'yes',
        'try': '2',
        'why': 'background',
      });
    });
  });

  test('Zigbee2MQTT gets two minutes to answer, not 30 seconds', () {
    // It first asks the coordinator, queued behind the dashboard's device
    // requests: 1 in 7 automatic backups ran out of 30 s (Nov 10-13).
    expect(hubBackupWait, const Duration(minutes: 2));
  });

  test('a slow answer is kept while the request still waits', () async {
    final link = _Link();
    link.onPublish = (topic, payload) => Timer(
      const Duration(milliseconds: 60),
      () => link.emit(
        'zigbee2mqtt/bridge/response/backup',
        jsonEncode({
          'status': 'ok',
          'transaction': _tx(payload),
          'data': {'zip': base64Encode(_zip)},
        }),
      ),
    );
    final answer = await requestHubBackup(
      link,
      'zigbee2mqtt',
      within: const Duration(milliseconds: 500),
    );
    expect(answer, isA<HubBackupZip>());
  });

  group('waiting for the dashboard to go quiet', () {
    test('returns at once when nothing was asked', () async {
      fakeAsync((async) {
        var done = false;
        waitForQuiet(() => null, now: () => async.getClock(DateTime(2026)).now())
            .then((_) => done = true);
        async.flushMicrotasks();
        expect(done, isTrue);
      });
    });

    test('waits until the last request is 10 s old', () async {
      fakeAsync((async) {
        DateTime now() => async.getClock(DateTime(2026)).now();
        final last = now();
        var done = false;
        waitForQuiet(() => last, now: now).then((_) => done = true);
        async.elapse(const Duration(seconds: 9));
        expect(done, isFalse);
        async.elapse(const Duration(seconds: 2));
        expect(done, isTrue);
      });
    });

    test('gives up after 40 s of steady requests', () async {
      fakeAsync((async) {
        DateTime now() => async.getClock(DateTime(2026)).now();
        var done = false;
        waitForQuiet(now, now: now).then((_) => done = true);
        async.elapse(const Duration(seconds: 39));
        expect(done, isFalse);
        async.elapse(const Duration(seconds: 2));
        expect(done, isTrue);
      });
    });
  });

  test('backup durations are counted in four buckets', () {
    expect(hubBackupTook(const Duration(seconds: 1)), 'under_10s');
    expect(hubBackupTook(const Duration(seconds: 29)), '10_30s');
    expect(hubBackupTook(const Duration(seconds: 45)), '30_60s');
    expect(hubBackupTook(const Duration(seconds: 90)), 'over_60s');
  });
}
