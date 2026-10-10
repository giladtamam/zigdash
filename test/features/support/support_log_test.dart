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
}
