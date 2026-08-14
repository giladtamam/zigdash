import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../../bin/smoke.dart' as smoke;

void main() {
  test(
    'normal delivery output preserves the legacy topic-tab-payload format',
    () {
      expect(
        smoke.formatSmokeDelivery('zigbee2mqtt/lamp', '{"state":"ON"}'),
        'zigbee2mqtt/lamp\t{"state":"ON"}',
      );
    },
  );

  test('outage delivery output includes its delivery number', () {
    expect(
      smoke.formatSmokeDelivery(
        'zigbee2mqtt/lamp',
        '{"state":"ON"}',
        deliveryNumber: 2,
      ),
      '[delivery 2]\tzigbee2mqtt/lamp\t{"state":"ON"}',
    );
  });

  test('checkpoint confirmation rejects EOF', () async {
    expect(await smoke.checkpointConfirmed(() async => null), isFalse);
  });

  test('checkpoint confirmation accepts an empty Enter line', () async {
    expect(await smoke.checkpointConfirmed(() async => ''), isTrue);
  });

  test('event loop continues while checkpoint input is pending', () async {
    final input = Completer<String?>();
    var timerCompleted = false;
    final confirmation = smoke.checkpointConfirmed(() => input.future);

    Timer.run(() => timerCompleted = true);
    await Future<void>.delayed(Duration.zero);

    expect(timerCompleted, isTrue);
    input.complete('');
    expect(await confirmation, isTrue);
  });

  test('session cleans up every resource when prompt input throws', () async {
    final cleanup = <String>[];
    final errors = <Object>[];

    final completed = await smoke.runSmokeSession(
      run: () async => throw FormatException('invalid stdin UTF-8'),
      cancelMessages: () async => cleanup.add('messages'),
      disposeManager: () async => cleanup.add('manager'),
      cancelStatus: () async => cleanup.add('status'),
      onError: (error, _) => errors.add(error),
    );

    expect(completed, isFalse);
    expect(cleanup, ['messages', 'manager', 'status']);
    expect(errors.single, isA<FormatException>());
  });

  test(
    'session continues cleanup after an earlier cleanup hook throws',
    () async {
      final cleanup = <String>[];
      final errors = <Object>[];

      final completed = await smoke.runSmokeSession(
        run: () async => true,
        cancelMessages: () async {
          cleanup.add('messages');
          throw StateError('cancel failed');
        },
        disposeManager: () async => cleanup.add('manager'),
        cancelStatus: () async => cleanup.add('status'),
        onError: (error, _) => errors.add(error),
      );

      expect(completed, isFalse);
      expect(cleanup, ['messages', 'manager', 'status']);
      expect(errors.single, isA<StateError>());
    },
  );
}
