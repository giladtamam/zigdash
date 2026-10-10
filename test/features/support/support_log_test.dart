import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/support/support_details.dart';
import 'package:zigdash/features/support/support_log.dart';

void main() {
  const scan = ScanSummary(
      widened: true, hostsTried: 1018, brokersFound: 0, network: 'Wi-Fi');

  test('records the last failure and scan, and persists them', () async {
    String? saved;
    final log = SupportLog(read: () async => saved, write: (s) async => saved = s);
    await log.recordFailure(FailureKind.loginRejected);
    await log.recordScan(scan);
    expect(log.lastFailure, FailureKind.loginRejected);
    expect(log.lastScan, scan);

    final reopened =
        SupportLog(read: () async => saved, write: (s) async => saved = s);
    await reopened.load();
    expect(reopened.lastFailure, FailureKind.loginRejected);
    expect(reopened.lastScan, scan);
  });

  test('a successful connection clears both', () async {
    String? saved;
    final log = SupportLog(read: () async => saved, write: (s) async => saved = s);
    await log.recordFailure(FailureKind.timedOut);
    await log.recordScan(scan);
    await log.clear();
    expect(log.lastFailure, isNull);
    expect(log.lastScan, isNull);
    expect(saved, isNull);
  });

  test('storage errors and junk never break it', () async {
    final log = SupportLog(
        read: () async => throw StateError('no disk'),
        write: (_) async => throw StateError('no disk'));
    await log.load();
    await log.recordFailure(FailureKind.refused);
    expect(log.lastFailure, FailureKind.refused);

    final junk = SupportLog(read: () async => '{not json', write: (_) async {});
    await junk.load();
    expect(junk.lastFailure, isNull);

    final unknownKind = SupportLog(
        read: () async => '{"failure":"fromTheFuture"}', write: (_) async {});
    await unknownKind.load();
    expect(unknownKind.lastFailure, isNull);
  });

  test('clear removes an earlier session\'s file even before any read',
      () async {
    String? saved = '{"failure":"timedOut"}';
    final log = SupportLog(read: () async => saved, write: (s) async => saved = s);
    await log.clear();
    expect(saved, isNull);
    await log.recordScan(scan);
    expect(log.lastFailure, isNull, reason: 'the stale failure must not return');
  });

  test('a record made during the first read is not overwritten by it',
      () async {
    final gate = Completer<String?>();
    String? saved;
    final log = SupportLog(read: () => gate.future, write: (s) async => saved = s);
    final reading = log.load();
    final recording = log.recordScan(scan);
    gate.complete('{"scan":{"widened":false,"hostsTried":1,"brokersFound":0}}');
    await reading;
    await recording;
    expect(log.lastScan, scan);
    expect(saved, contains('1018'));
  });
}
